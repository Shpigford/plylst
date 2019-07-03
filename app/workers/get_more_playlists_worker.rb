class GetMorePlaylistsWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform(playlist_owner, playlist_id)
    new_playlist = RSpotify::Playlist.find(playlist_owner, playlist_id)
    
    (0..1000).step(50) do |n|
      tracks = new_playlist.tracks(limit: 50, offset: n)
      break if tracks.blank? or tracks.size == 0

      SaveTracksWorker.perform_async(nil, tracks.map(&:id), 'top') if tracks.present?
    end
  end
end
