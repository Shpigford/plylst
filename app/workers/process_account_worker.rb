class ProcessAccountWorker
  include Sidekiq::Worker

  sidekiq_options queue: :critical, lock: :while_executing, on_conflict: :reject

  def perform(user_id)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)
      track_ids = Array.new
      
      spotify.saved_tracks
      
      total_tracks = spotify.total

      (0..total_tracks+50).step(50) do |n|
        ProcessTracksWorker.perform_async(user.id, n)
      end
      
      ProcessAlbumsWorker.set(queue: :slow).perform_async(user.id)
      ProcessPlaylistsWorker.set(queue: :slow).perform_async(user.id)
      BuildUserGenresWorker.set(queue: :critical).perform_in(30.seconds, user.id)
      UpdatePlayDataWorker.perform_in(60.seconds, user.id)
      RecentlyStreamedWorker.perform_in(60.seconds, user.id)
    end
  end
end
