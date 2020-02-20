class AddCatalogToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :catalog, :string, default: 'songs'
    add_index :playlists, :catalog
  end
end
