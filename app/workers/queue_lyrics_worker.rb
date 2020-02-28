class QueueLyricsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :lyrics, lock: :while_executing, on_conflict: :reject

  def perform
    Track.where(lyrics: nil).find_each do |track|
      if track.lyrics.blank?
        GetLyricsWorker.set(queue: :lyrics).perform_async(track.id) if track.lyrics_last_checked_at.blank? or track.lyrics_last_checked_at < 90.days.ago
      end
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Build Lyrics', cron: '0 3 * * *', class: 'QueueLyricsWorker')