class AddAudioFeatureIndices < ActiveRecord::Migration[5.2]
  def change
    add_index :tracks, :audio_features, using: :gin
  end
end
