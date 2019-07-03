class GetMoreNewReleasesWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform
    # New Releases
    new_releases = RSpotify::Album.new_releases(limit:50, offset: 0)
    new_releases.each do |new_release|
      SaveTracksWorker.perform_async(nil, new_release.tracks.map(&:id), 'top') if new_release.tracks.present?
    end

    sleep(30.seconds)
    
    new_releases = RSpotify::Album.new_releases(limit:50, offset: 50)
    new_releases.each do |new_release|
      SaveTracksWorker.perform_async(nil, new_release.tracks.map(&:id), 'top') if new_release.tracks.present?
    end
  end
end
