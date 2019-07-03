class GetMoreArtistsWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform
    Artist.all.find_each do |artist|
      GetMoreArtistsTopTracksWorker.perform_async(artist.spotify_id)
    end
  end
end
