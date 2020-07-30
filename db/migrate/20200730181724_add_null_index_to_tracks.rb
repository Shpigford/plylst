class AddNullIndexToTracks < ActiveRecord::Migration[6.0]
  def change
    add_index :tracks, [:key, :audio_features_last_checked], where: "key is null"
    add_index :tracks, :key, where: "key is null", name: 'tracks_key_is_null'
  end
end
