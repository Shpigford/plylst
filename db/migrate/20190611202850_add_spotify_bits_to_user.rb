class AddSpotifyBitsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :settings, :string
  end
end
