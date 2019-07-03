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

    # If there are no missing IDs, STOP THAT JUNK
    if missing_ids.present?
      # Make the Spotify API call to get all of the tracks
      spotify_tracks = RSpotify::Track.find(missing_ids)

      # Looop through the returned tracks
      spotify_tracks.each do |spotify_track|

        # Search to see if the track already exists, if it does not, initialize a new object based on the Spotify ID
        track = Track.where(spotify_id: spotify_track.id).first_or_initialize(spotify_id: spotify_track.id)

        # If it's a new track record, do this
        if track.new_record?
          spotify_artist = spotify_track.artists.first
          audio_feature_ids.push(spotify_track.id)

          # Search to see if the artist for the track already exists, if it does not, initialize a new object
          artist = Artist.where(spotify_id: spotify_artist.id).first_or_initialize(spotify_id: spotify_artist.id)

          # If it's a new artist record, save the initialized new object and spin off a separate worker to build the artist
          if artist.new_record?
            artist.save
            BuildArtistWorker.perform_async(artist.id)
          end

          # Search to see if the album for the track already exists, if it does not, initialize a new object
          spotify_album = spotify_track.album
          album = Album.where(spotify_id: spotify_album.id).first_or_initialize(spotify_id: spotify_album.id)

          # If it's a new album record, save the initialized new object and spin off a separate worker to build the album
          if album.new_record?
            album.artist = artist
            album.save
            BuildAlbumWorker.perform_async(album.id)
          end

          # Fill in the data for the track and save it
          track.artist = artist
          track.album = album
          track.duration = spotify_track.duration_ms
          track.explicit = spotify_track.explicit
          track.link = spotify_track.external_urls['spotify']
          track.name = spotify_track.name
          track.popularity = spotify_track.popularity
          track.preview_url = spotify_track.preview_url
          track.save
        end

        # If this worker was called with 'added', we're adding these tracks to the User's library as a track they have saved/followed
        # So, we need to check for that in the Follow table and update accordingly
        if kind == 'added'
          user.tracks << track unless Follow.where(user: user, track: track).present?
          follow = Follow.where(user: user, track: track).first
          added_at = tracks_with_date.select{|(x, y)| x == spotify_track.id}.first[1].to_time
          follow.update_attribute(:added_at, added_at)

        # If this track was created from the "RecentlyStreamedWorker" worker, be sure to add that stream
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

      # Build the "audio features" for new tracks
      AudioFeaturesWorker.perform_async(audio_feature_ids)
    end
  end
end
