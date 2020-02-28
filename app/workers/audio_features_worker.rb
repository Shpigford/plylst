class AudioFeaturesWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :slow, lock: :while_executing

  def perform(track_ids)
    tracks = Track.where(spotify_id: track_ids, key: nil)
    tracks_with_spotify_ids = tracks.pluck(:spotify_id)

    spotify_tracks = RSpotify::AudioFeatures.find(tracks_with_spotify_ids)
    
    spotify_tracks.each do |spotify_track|
      if spotify_track.present?
        track = tracks.find{|a| a.spotify_id == spotify_track.id}
        track.update_columns(
          acousticness: spotify_track.acousticness,
          danceability: spotify_track.danceability,
          energy: spotify_track.energy,
          instrumentalness: spotify_track.instrumentalness,
          key: spotify_track.key,
          liveness: spotify_track.liveness,
          loudness: spotify_track.loudness,
          mode: spotify_track.mode,
          speechiness: spotify_track.speechiness,
          tempo: spotify_track.tempo,
          time_signature: spotify_track.time_signature,
          valence: spotify_track.valence,
          audio_features_last_checked: Time.now
        )
      end
    end
    
  end
end
