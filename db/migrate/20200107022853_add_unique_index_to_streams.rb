class AddUniqueIndexToStreams < ActiveRecord::Migration[5.2]
  def change
    add_index :streams, [:user_id, :track_id, :played_at], unique: true
  end
end
