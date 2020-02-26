class AddSpotifyLinkToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :link, :text
  end
end
