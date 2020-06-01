class BuildPlaylistWorker
  include Sidekiq::Worker
  include ApplicationHelper

  sidekiq_options queue: :critical, lock: :while_executing, on_conflict: :reject

  def perform(playlist_id, spotify_playlist_id)
    playlist = Playlist.find(playlist_id)
    user = playlist.user

    if user.active?
      # Refresh the connection
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)

      begin
        spotify_playlist = RSpotify::Playlist.find(user.uid, spotify_playlist_id)
      rescue RestClient::NotFound => e
      rescue RestClient::Unauthorized, RestClient::BadRequest => e
        #user.increment!(:authorization_fails)
  
        # Deactivate user if we don't have the right permissions and if their authorization has failed a crap ton of times
        #user.update_attribute(:active, false) if user.authorization_fails >= 10
      end

      total = 0

      # Thanks to Spotify API limits, we need to divide the remove_tracks! call in to groups of 100
      total = spotify_playlist.total
      times_to_loop = (total.to_f / 100).ceil

      if total <= 0 or playlist.auto_update.present?
        begin
          times_to_loop.times { 
            playlist_tracks = spotify_playlist.tracks
            spotify_playlist.remove_tracks!(playlist_tracks) if playlist_tracks.present?
          }
        rescue RestClient::BadRequest => e
        end
      end

      spotify_playlist.change_details!(description: "Created with PLYLST.app! #{playlist.translated_rules}", public: playlist.public)

      if total <= 0 or playlist.auto_update.present?
        tracks = playlist.filtered_tracks(user).pluck(:id)
        playlist.update_attributes(track_cache: tracks)

        tracks_formatted = Track.where(id: tracks).pluck(:spotify_id)
        tracks_formatted_ids = tracks_formatted.map{|x| x.prepend('spotify:track:')}

        # Divide tracks in to groups of 100, due to Spotify API limit
        tracks_formatted_ids.each_slice(100) do |group|
          spotify_playlist.add_tracks!(group)
        end
      end

      playlist.update_columns(spotify_id: spotify_playlist.id)

    end
  end
end
