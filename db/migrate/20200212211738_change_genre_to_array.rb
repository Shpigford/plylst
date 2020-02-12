class ChangeGenreToArray < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :genres, 'text USING CAST(genres AS text)', null: true
    change_column_default(:users, :genres, nil)
  end

  def down
    change_column :users, :genres, :jsonb, using: 'genres::text::jsonb', default: {}
  end
end
