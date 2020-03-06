class ProcessTracksWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing, on_conflict: :reject

  def perform(user_id, offset)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)
      track_ids = Array.new

      begin
        tracks = spotify.saved_tracks(limit: 50, offset: offset)
      rescue RestClient::Unauthorized, RestClient::Forbidden => e
        user.increment!(:authorization_fails)
    
        # Deactivate user if we don't have the right permissions and if their authorization has failed a crap ton of times
        user.update_attribute(:active, false) if user.authorization_fails >= 10
      rescue RestClient::BadGateway => e
      end
    
      if tracks.present?
        tracks_added_at = spotify.tracks_added_at
        
        SaveTracksWorker.perform_async(user.id, tracks_added_at.to_a, 'added')
      end
    end
  end
end
