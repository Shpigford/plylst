class CreateTracks < ActiveRecord::Migration[5.2]
  def change
    create_table :tracks do |t|
      t.references :album, foreign_key: true
      t.references :artist, foreign_key: true
      t.integer :duration
      t.boolean :explicit
      t.text :spotify_id
      t.text :link
      t.text :name
      t.integer :popularity
      t.text :preview_url

      t.timestamps
    end
  end
end
