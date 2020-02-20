class AddDefaultToPlays < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:follows, :plays, from: nil, to: 0)
    change_column_null(:follows, :plays, false, 0)
  end
end
