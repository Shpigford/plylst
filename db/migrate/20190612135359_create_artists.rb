class CreateArtists < ActiveRecord::Migration[5.2]
  def change
    create_table :artists do |t|
      t.text :name
      t.text :spotify_id
      t.integer :followers
      t.integer :popularity
      t.text :images
      t.text :link
      t.jsonb :genres

      t.timestamps
    end
  end
end
