class ProcessPlaylistsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(user_id)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)

      (0..1000).step(50) do |n|
        spotify_playlists = spotify.playlists(limit:50, offset: n)
        break if spotify_playlists.size == 0

        spotify_playlists.each do |spotify_playlist|
          # Make sure we aren't importing PLYLST-generated playlists and that we're only importing playlists the user created themselves (vs others they may be following)
          if !spotify_playlist.name.include?("PLYLST") and spotify_playlist.owner.id == user.uid
            total = spotify_playlist.total

            (0..total).step(100) do |n|
              spotify_playlist.tracks(limit: 100, offset: n)
              tracks_added_at = spotify_playlist.tracks_added_at.to_a

              SaveTracksWorker.perform_async(user.id, tracks_added_at, 'added')
            end
          end
        end
      end
    end
  end
end
