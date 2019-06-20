class AddGenresToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :genres, :jsonb, default: {}
  end
end
