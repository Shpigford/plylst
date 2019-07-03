class GetLyricsWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :slow

  # sidekiq_throttle({
  #   :concurrency => { :limit => 10 },
  #   :threshold => { :limit => 120, :period => 1.minute }
  # })

  def perform(track_id)
    track = Track.find(track_id)

    if track.present? and track.lyrics == nil
      songs = Genius::Song.search("#{track.name} by #{track.artist.name}")
      if songs.present?
        page = Nokogiri::HTML(HTTParty.get(songs.first.url))
        lyrics = page.css('.lyrics').text.squish

        track.update_attribute(:lyrics, lyrics)
      end
    end
  end
end
