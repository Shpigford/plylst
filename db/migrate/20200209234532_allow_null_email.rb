class AllowNullEmail < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:users, :email, true)
  end
end
