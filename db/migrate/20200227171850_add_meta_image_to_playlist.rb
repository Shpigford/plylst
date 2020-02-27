class AddMetaImageToPlaylist < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :meta_image, :text
  end
end
