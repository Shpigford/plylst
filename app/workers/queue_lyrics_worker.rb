class QueueLyricsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :slow

  def perform
    Track.where(lyrics: nil).find_each do |track|
      GetLyricsWorker.perform_async(track.id) if track.lyrics.blank?
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Build Lyrics', cron: '0 3 * * *', class: 'QueueLyricsWorker')