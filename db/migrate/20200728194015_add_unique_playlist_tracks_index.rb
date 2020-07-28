class AddUniquePlaylistTracksIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :playlist_tracks, [:track_id, :playlist_id], unique: true
  end
end
