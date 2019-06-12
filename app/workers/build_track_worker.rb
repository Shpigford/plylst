class BuildTrackWorker
  include Sidekiq::Worker

  def perform(track)
    # Do something
  end
end
