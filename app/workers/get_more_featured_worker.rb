class GetMoreFeaturedWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform
    # Featured
    featured_playlists = RSpotify::Playlist.browse_featured(limit: 50)
    featured_playlists.each do |playlist|
      new_playlist = RSpotify::Playlist.find(playlist.owner.id, playlist.id)
      
      (0..1000).step(50) do |n|
        tracks = new_playlist.tracks(limit: 50, offset: n)
        break if tracks.blank? or tracks.size == 0

        SaveTracksWorker.set(queue: :slow).perform_async(nil, tracks.map(&:id), 'top') if tracks.present?
      end
    end
  end
end
