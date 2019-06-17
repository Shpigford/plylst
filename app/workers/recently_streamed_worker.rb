class RecentlyStreamedWorker
  include Sidekiq::Worker

  def perform

    User.all.each do |user|
      user = User.find user.id
      connection = user.settings.to_hash
      spotify = RSpotify::User.new(connection)
      recent_tracks = spotify.recently_played(limit: 50)

      recent_track_ids = Array.new

      recent_tracks.each do |track|
        recent_track_ids.push([track.id, track.played_at])
      end

      SaveTracksWorker.perform_async(user.id, recent_track_ids, 'streamed')
    end

  end
end

# Sidekiq::Cron::Job.create(name: 'Recently Streamed', cron: '*/15 * * * *', class: 'RecentlyStreamedWorker')