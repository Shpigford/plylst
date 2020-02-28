class RecentlyStreamedWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing, on_conflict: :reject

  def perform(user_id)
    user = User.find user_id

    if user.active?
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)

      begin
        recent_tracks = spotify.recently_played(limit: 50)
      rescue RestClient::Unauthorized, RestClient::BadRequest => e
        user.increment!(:authorization_fails)

        # Deactivate user if we don't have the right permissions and if their authorization has failed a crap ton of times
        user.update_attribute(:active, false) if user.authorization_fails >= 10
      end

      if recent_tracks.present?
        recent_track_ids = Array.new

        recent_tracks.each do |track|
          recent_track_ids.push([track.id, track.played_at])
        end

        SaveTracksWorker.perform_async(user.id, recent_track_ids, 'streamed')
      end
    end
  end
end