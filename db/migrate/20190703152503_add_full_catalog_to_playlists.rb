class AddFullCatalogToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :full_catalog, :boolean, default: false
    add_index :playlists, :full_catalog
  end
end
