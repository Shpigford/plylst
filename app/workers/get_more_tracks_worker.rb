class GetMoreTracksWorker
  include Sidekiq::Worker

  sidekiq_options queue: :slow, lock: :while_executing

  def perform 
    GetMoreCategoriesWorker.perform_async
    GetMoreFeaturedWorker.perform_async
    GetMoreNewReleasesWorker.perform_async
    GetMoreArtistsWorker.perform_async
  end
end

# Sidekiq::Cron::Job.create(name: 'Get More Tracks', cron: '0 1 * * *', class: 'GetMoreTracksWorker')