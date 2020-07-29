class AddLastProcessedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_processed_at, :datetime
  end
end
