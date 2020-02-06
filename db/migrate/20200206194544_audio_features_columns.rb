class AudioFeaturesColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :tracks, :key, :integer
    add_column :tracks, :mode, :integer
    add_column :tracks, :tempo, :decimal
    add_column :tracks, :energy, :decimal
    add_column :tracks, :valence, :decimal
    add_column :tracks, :liveness, :decimal
    add_column :tracks, :loudness, :decimal
    add_column :tracks, :speechiness, :decimal
    add_column :tracks, :acousticness, :decimal
    add_column :tracks, :danceability, :decimal
    add_column :tracks, :time_signature, :integer
    add_column :tracks, :instrumentalness, :decimal

    add_index :tracks, :key
    add_index :tracks, :mode
    add_index :tracks, :tempo
    add_index :tracks, :energy
    add_index :tracks, :valence
    add_index :tracks, :liveness
    add_index :tracks, :loudness
    add_index :tracks, :speechiness
    add_index :tracks, :acousticness
    add_index :tracks, :danceability
    add_index :tracks, :time_signature
    add_index :tracks, :instrumentalness
  end
end
