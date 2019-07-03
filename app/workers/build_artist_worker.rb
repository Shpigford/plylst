class BuildArtistWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing

  def perform(artist_id)
    artist = Artist.find artist_id

    spotify_artist = RSpotify::Artist.find(artist.spotify_id)

    image = spotify_artist.images.first['url'] if spotify_artist.images.present?

    spotify_genres = spotify_artist.genres.map(&:downcase)

    all_genres = artist.genres.to_set
    all_genres = all_genres.merge(spotify_genres)


    artist.update_attributes(
      name: spotify_artist.name,
      followers: spotify_artist.followers['total'], 
      popularity: spotify_artist.popularity, 
      images: image, 
      link: spotify_artist.external_urls['spotify'], 
      genres: spotify_artist.genres
    )
  end
end
