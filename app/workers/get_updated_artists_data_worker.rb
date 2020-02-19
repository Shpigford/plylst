class GetUpdatedArtistsDataWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :slow

  def perform(artist_ids)
    spotify_ids = Artist.find(artist_ids).pluck(:spotify_id)
    spotify_artists = RSpotify::Artist.find(spotify_ids)

    spotify_artists.each do |spotify_artist|
      GetMoreArtistsTopTracksWorker.set(queue: :slow).perform_async(spotify_artist.id)

      image = spotify_artist.images.first['url'] if spotify_artist.images.present?

      spotify_genres = spotify_artist.genres.map(&:downcase)
      
      artist = Artist.find_by(spotify_id: spotify_artist.id)

      if artist.present?
        artist.update_columns(
          name: spotify_artist.name,
          followers: spotify_artist.followers['total'], 
          popularity: spotify_artist.popularity, 
          images: image,
          genres: spotify_genres,
          last_checked_at: Time.now
        )
      end
    end
  end
end
