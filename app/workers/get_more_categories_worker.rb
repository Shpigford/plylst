class GetMoreCategoriesWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform
    # Categories
    RSpotify::Category.list(limit:50).each do |category|
      playlists = category.playlists(limit:50)

      if playlists.present?
        playlists.each do |playlist|
          GetMorePlaylistsWorker.perform_async(playlist.owner.id, playlist.id)
        end
      end
      sleep(3.seconds)
    end
  end
end
