class GetUpdatedAlbumsDataWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform(albums_ids)
    spotify_ids = Album.find(albums_ids).pluck(:spotify_id)
    spotify_albums = RSpotify::Album.find(spotify_ids)

    spotify_albums.each do |spotify_album|
      album = Album.find_by(spotify_id: spotify_album.id)

      if album.present?
        image = spotify_album.images.first['url'] if spotify_album.images.present?

        if spotify_album.artists.present? && spotify_album.artists.first.name == 'Various Artists'
          album_type = 'compilation'
        else
          album_type = spotify_album.album_type
        end

        if spotify_album.release_date.present?
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
      
        album.update_attributes(
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
  end
end
