class AddPopularityIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :albums, :popularity
    add_index :artists, :popularity
    add_index :tracks, :popularity
  end
end
