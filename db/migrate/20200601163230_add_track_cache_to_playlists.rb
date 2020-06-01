class AddTrackCacheToPlaylists < ActiveRecord::Migration[6.0]
  def change
    add_column :playlists, :track_cache, :text, array: true, default: []
  end
end
