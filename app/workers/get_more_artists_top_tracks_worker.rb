class GetMoreArtistsTopTracksWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform(spotify_id)
    tracks = RSpotify::Artist.find(spotify_id).top_tracks('US')

    SaveTracksWorker.perform_async(nil, tracks.map(&:id), 'top') if tracks.present?
  end
end
