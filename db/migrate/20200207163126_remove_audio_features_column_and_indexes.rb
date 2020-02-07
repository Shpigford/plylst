class RemoveAudioFeaturesColumnAndIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_column :tracks, :audio_features, :jsonb

    remove_index :tracks, "(((audio_features->>'energy')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_energy')
    remove_index :tracks, "(((audio_features->>'tempo')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_tempo')
    remove_index :tracks, "(((audio_features->>'key')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_key')
    remove_index :tracks, "(((audio_features->>'danceability')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_danceability')
    remove_index :tracks, "(((audio_features->>'acousticness')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_acousticness')
    remove_index :tracks, "(((audio_features->>'speechiness')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_speechiness')
    remove_index :tracks, "(((audio_features->>'instrumentalness')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_instrumentalness')
    remove_index :tracks, "(((audio_features->>'valence')::numeric))" if index_name_exists?(:tracks, 'index_tracks_on_audio_features_valence')
  end
end
