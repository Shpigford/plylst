class GetMoreArtistsTopTracksWorker
  include Sidekiq::Worker

  sidekiq_options queue: :slow, lock: :while_executing, on_conflict: :reject

  def perform(spotify_id)
    tracks = RSpotify::Artist.find(spotify_id).top_tracks('US')

    Artist.find_by(spotify_id: spotify_id).touch(:last_checked_at)

    SaveTracksWorker.set(queue: :slow).perform_async(nil, tracks.map(&:id), 'top') if tracks.present?
  end
end
