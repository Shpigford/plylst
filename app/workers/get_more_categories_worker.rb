class GetMoreCategoriesWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform
    # Categories
    RSpotify::Category.list(limit:50).each do |category|
      playlists = category.playlists(limit:50)

      if playlists.present?
        playlists.each do |playlist|
          new_playlist = RSpotify::Playlist.find(playlist.owner.id, playlist.id)
          
          (0..1000).step(50) do |n|
            tracks = new_playlist.tracks(limit: 50, offset: n)
            break if tracks.blank? or tracks.size == 0

            SaveTracksWorker.perform_async(nil, tracks.map(&:id), 'top') if tracks.present?
          end
        end
      end
    end
  end
end
