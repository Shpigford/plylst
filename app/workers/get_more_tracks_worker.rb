class GetMoreTracksWorker
  include Sidekiq::Worker

  def perform
    # New Releases
    new_releases = RSpotify::Album.new_releases(limit:50, offset: 0)
    new_releases.each do |new_release|
      SaveTracksWorker.perform_async(nil, new_release.tracks.map(&:id), 'top') if new_release.tracks.present?
    end

    new_releases = RSpotify::Album.new_releases(limit:50, offset: 50)
    new_releases.each do |new_release|
      SaveTracksWorker.perform_async(nil, new_release.tracks.map(&:id), 'top') if new_release.tracks.present?
    end

    # Featured
    featured_playlists = RSpotify::Playlist.browse_featured(limit: 50)
    featured_playlists.each do |playlist|
      new_playlist = RSpotify::Playlist.find(playlist.owner.id, playlist.id)
      
      (0..1000).step(50) do |n|
        tracks = new_playlist.tracks(limit: 50, offset: n)
        break if tracks.blank? or tracks.size == 0

        SaveTracksWorker.perform_async(nil, tracks.map(&:id), 'top') if tracks.present?
      end
    end

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
