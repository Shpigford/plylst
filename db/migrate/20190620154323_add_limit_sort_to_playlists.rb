class AddLimitSortToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :limit, :integer, default: nil
    add_column :playlists, :sort, :string, default: nil
  end
end
