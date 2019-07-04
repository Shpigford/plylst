class AddArtistLastCheckedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :artists, :last_checked_at, :datetime
    add_index :artists, :last_checked_at
  end
end
