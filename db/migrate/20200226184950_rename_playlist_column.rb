class RenamePlaylistColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :playlists, :link, :spotify_id
    add_index :playlists, :spotify_id
  end
end
