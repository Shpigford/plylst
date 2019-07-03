class Indexarama < ActiveRecord::Migration[5.2]
  def change
    add_index :albums, :spotify_id
    add_index :artists, :spotify_id
    add_index :tracks, :explicit
  end
end
