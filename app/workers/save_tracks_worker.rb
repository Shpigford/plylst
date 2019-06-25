class SaveTracksWorker
  include Sidekiq::Worker

  def perform(user_id, tracks_with_date, kind = 'added')
    user = User.find user_id
    track_ids = tracks_with_date.map(&:first)

    spotify_tracks = RSpotify::Track.find(track_ids)

    spotify_tracks.each do |spotify_track|
      track = Track.where(spotify_id: spotify_track.id).first_or_initialize(spotify_id: spotify_track.id)

      if track.new_record?
        spotify_artist = spotify_track.artists.first
        artist = Artist.where(spotify_id: spotify_artist.id).first_or_initialize(spotify_id: spotify_artist.id)

        if artist.new_record?
          artist.save
          BuildArtistWorker.perform_async(artist.id)
        end

        spotify_album = spotify_track.album
        album = Album.where(spotify_id: spotify_album.id).first_or_initialize(spotify_id: spotify_album.id)

        if album.new_record?
          album.artist = artist
          album.save
          BuildAlbumWorker.perform_async(album.id)
        end

        track.artist = artist
        track.album = album
        track.duration = spotify_track.duration_ms
        track.explicit = spotify_track.explicit
        track.link = spotify_track.external_urls['spotify']
        track.name = spotify_track.name
        track.popularity = spotify_track.popularity
        track.preview_url = spotify_track.preview_url
        track.save

        GetLyricsWorker.perform_async(track.id) if ENV['genius']
      end

      if kind == 'added'
        user.tracks << track unless Follow.where(user: user, track: track).present?
        follow = Follow.where(user: user, track: track).first
        added_at = tracks_with_date.select{|(x, y)| x == spotify_track.id}.first[1].to_time
        follow.update_attribute(:added_at, added_at)
      elsif kind == 'streamed'
        follow = Follow.where(user: user, track: track).first

        if follow
          streams = tracks_with_date.select{|(x, y)| x == spotify_track.id}

          streams.each do |stream|
            time = stream[1].to_time
            stream = Stream.where(user: user, track: track, played_at: time).first_or_initialize(played_at: time)

            if stream.new_record?
              stream.save
            end
          end
        end
      end
    end

    AudioFeaturesWorker.perform_async(track_ids)
  end
end
