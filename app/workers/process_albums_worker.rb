class ProcessAlbumsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(user_id)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)

      albums = spotify.saved_albums
      
      (0..1000000000).step(50) do |n|
        albums = spotify.saved_albums(limit: 50, offset: n)
        break if albums.size == 0

        dates_added_at = spotify.tracks_added_at

        albums.each_with_index do |album, index|
          date_added = dates_added_at[index]
          tracks = album.tracks.map(&:id)

          tracks_added_at = tracks.map { |t| [t, date_added] }

          SaveTracksWorker.perform_async(user.id, tracks_added_at, 'added')
        end 
      end
    end
  end
end
