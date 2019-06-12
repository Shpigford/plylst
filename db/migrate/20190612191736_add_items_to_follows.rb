class AddItemsToFollows < ActiveRecord::Migration[5.2]
  def change
    add_column :follows, :added_at, :datetime
    add_column :follows, :last_played_at, :datetime
    add_column :follows, :plays, :integer
  end
end
