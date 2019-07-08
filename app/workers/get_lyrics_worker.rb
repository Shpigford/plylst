class GetLyricsWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: :slow, lock: :while_executing

  # sidekiq_throttle({
  #   :concurrency => { :limit => 10 },
  #   :threshold => { :limit => 120, :period => 1.minute }
  # })

  def perform(track_id)
    track = Track.find(track_id)

    if track.present? and track.lyrics == nil
      songs = Genius::Song.search("#{track.name} by #{track.artist.name}")
      if songs.present?
        if songs.first.primary_artist.name.downcase == track.artist.name.downcase and songs.first.title.downcase == track.name.downcase
          page = Nokogiri::HTML(HTTParty.get(songs.first.url))
          lyrics = page.css('.lyrics').text.strip

          track.update_attribute(:lyrics, lyrics)
        end
      end
    end
  end
end
