class FollowWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id

    if user.settings
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)
      artist_ids = Array.new
      
      (0..100000000000).step(50) do |n|
        tracks = spotify.saved_tracks(limit: 50, offset: n)
        break if tracks.size == 0
        tracks.each do |track|
          # Only pull the primary artist from the track
          artist_ids.push(track.artists.first.name)
        end
      end

      artist_ids = artist_ids.uniq.compact.each_slice(50).to_a
      artist_ids.each do |artist_group|
        FollowArtistsWorker.perform_async(user.id, artist_group)
      end
    end
  end
end
