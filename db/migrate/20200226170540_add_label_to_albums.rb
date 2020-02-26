class AddLabelToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :label, :string
    add_index :albums, :label
  end
end
