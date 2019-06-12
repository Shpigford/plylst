class CreateAlbums < ActiveRecord::Migration[5.2]
  def change
    create_table :albums do |t|
      t.references :artist, foreign_key: true
      t.text :name
      t.text :image
      t.date :release_date
      t.text :spotify_id
      t.text :link
      t.integer :popularity
      t.string :album_type

      t.timestamps
    end
  end
end
