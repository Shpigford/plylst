class AddFiltersToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :filters, :jsonb, null: false, default: {}
  end
end
