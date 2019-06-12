class CreateStreams < ActiveRecord::Migration[5.2]
  def change
    create_table :streams do |t|
      t.references :user, foreign_key: true
      t.references :track, foreign_key: true
      t.datetime :played_at

      t.timestamps
    end
  end
end
