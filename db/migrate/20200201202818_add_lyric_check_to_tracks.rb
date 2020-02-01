class AddLyricCheckToTracks < ActiveRecord::Migration[5.2]
  def change
    add_column :tracks, :lyrics_last_checked_at, :datetime
    add_index :tracks, :lyrics_last_checked_at
  end
end
