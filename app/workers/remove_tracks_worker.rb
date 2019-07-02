class RemoveTracksWorker
  include Sidekiq::Worker

  def perform(user_id, track_ids)
    user = User.find user_id
    connection = user.settings.to_hash
    spotify = RSpotify::User.new(connection)

    if user.active?
      begin
        saved = spotify.saved_tracks?(track_ids)
      rescue RestClient::Forbidden => e
        # Deactivate user if we don't have the right permissions
        user.update_attribute(:active, false)
      end

      if saved.present?
        track_saved = Hash[track_ids.zip(saved)]

        removed_tracks = track_saved.delete_if { |k,v| v === true}

        removed_tracks.each do |removed_track|
          track = Track.find_by(spotify_id: removed_track[0])
          
          user.follows.find_by(track: track).update_attribute(:active, false)
        end
      end
    end

  end
end
