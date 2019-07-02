class AddIndexesToThings < ActiveRecord::Migration[5.2]
  def change
    add_index :tracks, :spotify_id
  end
end
