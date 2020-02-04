class AddMoreAudioFeatureIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :tracks, "(((audio_features->>'energy')::numeric))", name: 'index_tracks_on_audio_features_energy'
    add_index :tracks, "(((audio_features->>'tempo')::numeric))", name: 'index_tracks_on_audio_features_tempo'
    add_index :tracks, "(((audio_features->>'key')::numeric))", name: 'index_tracks_on_audio_features_key'
    add_index :tracks, "(((audio_features->>'danceability')::numeric))", name: 'index_tracks_on_audio_features_danceability'
    add_index :tracks, "(((audio_features->>'acousticness')::numeric))", name: 'index_tracks_on_audio_features_acousticness'
    add_index :tracks, "(((audio_features->>'speechiness')::numeric))", name: 'index_tracks_on_audio_features_speechiness'
    add_index :tracks, "(((audio_features->>'instrumentalness')::numeric))", name: 'index_tracks_on_audio_features_instrumentalness'
    add_index :tracks, "(((audio_features->>'valence')::numeric))", name: 'index_tracks_on_audio_features_valence'
  end
end
