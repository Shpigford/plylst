class BuildAlbumWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing, on_conflict: :reject

  def perform(album_id)
    album = Album.find album_id

    spotify_album = RSpotify::Album.find(album.spotify_id)

    image = spotify_album.images.first['url'] if spotify_album.images.present?

    if spotify_album.artists.present? && spotify_album.artists.first.name == 'Various Artists'
      album_type = 'compilation'
    else
      album_type = spotify_album.album_type
    end

    if album.release_date.blank?
      if spotify_album.release_date_precision == 'year'
        date = Date.strptime("#{spotify_album.release_date}-01-01", '%Y-%m-%d')
      elsif spotify_album.release_date_precision == 'month'
        date = Date.strptime("#{spotify_album.release_date}-01", '%Y-%m-%d')
      else
        date = spotify_album.release_date.to_date
      end
    else
      date = nil
    end

    album.update(
      name: spotify_album.name,
      image: image, 
      release_date: date, 
      link: spotify_album.external_urls['spotify'], 
      popularity: spotify_album.popularity, 
      album_type: album_type,
      label: spotify_album.label,
      last_checked_at: Time.now
    )
  end
end
