class AddLastCheckedAtToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :last_checked_at, :datetime
    add_index :albums, :last_checked_at
  end
end
