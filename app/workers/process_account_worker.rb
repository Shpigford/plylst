class ProcessAccountWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id

    connection = user.settings.to_hash
    spotify = RSpotify::User.new(connection)
    track_ids = Array.new
    
    (0..1000000000).step(50) do |n|
      tracks = spotify.saved_tracks(limit: 50, offset: n)
      tracks_added_at = spotify.tracks_added_at
      break if tracks.size == 0

      SaveTracksWorker.perform_async(user.id, tracks_added_at.to_a, 'added')
    end

    # track_ids = track_ids.uniq.compact.each_slice(50).to_a

    # track_ids.each do |track_group|
    #   SaveTracksWorker.perform_async(user.id, track_group)
    # end
  end
end
