class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.references :user, foreign_key: true
      t.references :track, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
