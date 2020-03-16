class BuildPlaylistsWorker
  include Sidekiq::Worker
  include ApplicationHelper

  sidekiq_options queue: :critical, lock: :while_executing, on_conflict: :reject

  def perform(user_id)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)

      begin
        spotify_playlists = spotify.playlists(limit:50)
      rescue RestClient::NotFound => e
      rescue RestClient::Unauthorized, RestClient::BadRequest => e
        user.increment!(:authorization_fails)

        # Deactivate user if we don't have the right permissions and if their authorization has failed a crap ton of times
        user.update_attribute(:active, false) if user.authorization_fails >= 10
      end

      user.playlists.find_each do |playlist|
        if spotify_playlists.present?
          existing_playlist = spotify_playlists.select{|key| key.name == "PLYLST: #{playlist.name}"}.first

          if existing_playlist.blank?
            existing_playlist = spotify.create_playlist!("PLYLST: #{playlist.name}", public: playlist.public)
          end

          BuildPlaylistWorker.perform_async(playlist.id, existing_playlist.id)
        end
      end
    end
  end
end
