class ProcessAccountWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(user_id)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)
      track_ids = Array.new
      
      (0..1000000000).step(50) do |n|
        begin
          tracks = spotify.saved_tracks(limit: 50, offset: n)
        rescue RestClient::BadGateway => e
          break
        end

        if tracks.present?
          tracks_added_at = spotify.tracks_added_at
          break if tracks.size == 0

          SaveTracksWorker.perform_async(user.id, tracks_added_at.to_a, 'added')
        else
          break
        end
      end

      BuildUserGenresWorker.perform_in(30.seconds, user.id)
      UpdatePlayDataWorker.perform_in(60.seconds, user.id)
      RecentlyStreamedWorker.perform_in(60.seconds, user.id)
    end
  end
end
