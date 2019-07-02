class AddMoreIndexesToThings < ActiveRecord::Migration[5.2]
  def change
    add_index :follows, [:user_id, :track_id]
  end
end
