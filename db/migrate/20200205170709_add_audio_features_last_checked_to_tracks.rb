class AddAudioFeaturesLastCheckedToTracks < ActiveRecord::Migration[5.2]
  def change
    add_column :tracks, :audio_features_last_checked, :datetime
    add_index :tracks, :audio_features_last_checked
  end
end
