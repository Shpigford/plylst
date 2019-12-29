class AddAutoUpdateToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :auto_update, :boolean, default: true
  end
end
