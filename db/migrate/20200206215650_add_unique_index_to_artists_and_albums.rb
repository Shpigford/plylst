class AddUniqueIndexToArtistsAndAlbums < ActiveRecord::Migration[5.2]
  def change
    remove_index :artists, :spotify_id
    add_index :artists, :spotify_id, unique: true

    remove_index :albums, :spotify_id
    add_index :albums, :spotify_id, unique: true

    remove_index :tracks, :spotify_id
    add_index :tracks, :spotify_id, unique: true
  end
end
