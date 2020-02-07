class GetMoreArtistsWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform
    Artist.all.find_each do |artist|
      popularity = artist.popularity.to_i
      case
        when popularity < 25
          days = 90
        when popularity < 50
          days = 60
        when popularity < 75
          days = 30
        else
          days = 10
      end

      GetMoreArtistsTopTracksWorker.set(queue: :slow).perform_async(artist.spotify_id) if artist.last_checked_at.blank? || artist.last_checked_at < days.day.ago
    end
  end
end
