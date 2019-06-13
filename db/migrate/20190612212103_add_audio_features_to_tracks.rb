class AddAudioFeaturesToTracks < ActiveRecord::Migration[5.2]
  def change
    add_column :tracks, :audio_features, :jsonb
  end
end
