class ProcessAudioFeaturesWorker
  include Sidekiq::Worker

  def perform
    Track.where(audio_features: {}).where('audio_features_last_checked < ? OR audio_features_last_checked IS NULL', 72.hours.ago).pluck(:spotify_id).each_slice(100) do |slice|
      AudioFeaturesWorker.set(queue: :slow).perform_async(slice)
    end
  end
end
