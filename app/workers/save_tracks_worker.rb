class SaveTracksWorker
  include Sidekiq::Worker

  def perform(user_id, tracks_with_date, kind = 'added')
    # Find user these tracks are associated with, if a user_id is passed
    user = User.find user_id if user_id.present?
    audio_feature_ids = Array.new

    # Check if `tracks_with_date` is actually a multi-dimensional array (meaning it has dates)
    if tracks_with_date.all? { |e| e.kind_of? Array }
      track_ids = tracks_with_date.map(&:first)
    else
      track_ids = tracks_with_date
    end

    # Let's do a quick call to see what tracks already exist so we don't unecessarily process existing tracks
    existing_ids = Track.where(spotify_id: track_ids).pluck(:spotify_id)
    missing_ids = (track_ids - existing_ids).uniq

    tracks_to_save = {}

    # If there are no missing IDs, STOP THAT JUNK
    if missing_ids.present?
      # Make the Spotify API call to get all of the tracks
      spotify_tracks = RSpotify::Track.find(missing_ids)
      spotify_artist_by_track = spotify_tracks.map{|t| [t.id, t.artists.first] }.to_h
      spotify_album_by_track = spotify_tracks.map{|t| [t.id, t.album] }.to_h

      artists = Artist.where(spotify_id: spotify_artist_by_track.values.flatten.map(&:id)).map{|a| [a.spotify_id, a] }.to_h
      albums = Album.where(spotify_id: spotify_album_by_track.values.flatten.map(&:id)).map{|a| [a.spotify_id, a] }.to_h

      # Looop through the returned tracks
      spotify_tracks.each do |spotify_track|
        # Initialize a new object based on the Spotify ID
        track = Track.new(spotify_id: spotify_track.id)
        audio_feature_ids.push(spotify_track.id)

        # Search to see if the artist for the track already exists, if it does not, initialize a new object
        # TODO: Save these in bulk too
        artists[spotify_track.artists.first.id] ||= Artist.create!(spotify_id: spotify_track.artists.first.id)
        BuildArtistWorker.perform_async(artist.id) if artists[spotify_track.artists.first.id].new_record?

        # Search to see if the album for the track already exists, if it does not, initialize a new object
        # TODO: Save these in bulk too
        albums[spotify_track.album.id] ||= Album.create!(spotify_id: spotify_track.album.id, artist: artists[spotify_track.artists.first.id])
        BuildAlbumWorker.perform_async(album.id) if albums[spotify_track.album.id].new_record?

        # Fill in the data for the track and save it
        track.artist = artists[spotify_track.artists.first.id]
        track.album = albums[spotify_track.album.id]
        track.duration = spotify_track.duration_ms
        track.explicit = spotify_track.explicit
        track.link = spotify_track.external_urls['spotify']
        track.name = spotify_track.name
        track.popularity = spotify_track.popularity
        track.preview_url = spotify_track.preview_url

        tracks_to_save[spotify_track.id] = track
      end
    end

    Track.import! tracks_to_save.values, on_duplicate_key_update: {conflict_target: [:spotify_id], columns: []}

    # If this worker was called with 'added', we're adding these tracks to the User's library as a track they have saved/followed
    # So, we need to check for that in the Follow table and update accordingly
    if kind == 'added'
      # Make the Spotify API call to get all of the tracks
      spotify_tracks = RSpotify::Track.find(track_ids)
      tracks = Track.where(spotify_id: track_ids)
      follows = []

      # Looop through the returned tracks
      spotify_tracks.each do |spotify_track|
        track = tracks.find{|a| a.spotify_id == spotify_track.id}

        if track.present?
          begin
            added_at = tracks_with_date.select{|(x, y)| x == spotify_track.id}.first[1].to_time
            follows < Follow.new(user: user, track: track, added_at: added_at)
          rescue
          end
        end
      end

      Follow.import follows, on_duplicate_key_update: {conflict_target: [:user_id, :track_id], columns: []}
    end


    # If this track was created from the "RecentlyStreamedWorker" worker, be sure to add that stream
    if kind == 'streamed'
      # Make the Spotify API call to get all of the tracks
      spotify_tracks = RSpotify::Track.find(track_ids)
      tracks = Track.where(spotify_id: track_ids)
      streams = []

      # Looop through the returned tracks
      spotify_tracks.each do |spotify_track|
        track = tracks.find{|a| a.spotify_id == spotify_track.id}

        if track.present?
          streams = tracks_with_date.select{|(x, y)| x == spotify_track.id}

          streams.each do |stream|
            time = stream[1].to_time
            streams << Stream.new(user: user, track: track, played_at: time)
          end
        end
      end

      Stream.import streams, on_duplicate_key_update: {conflict_target: [:user_id, :track_id, :played_at], columns: []}
    end

  end
end
