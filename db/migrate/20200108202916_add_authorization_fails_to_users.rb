class AddAuthorizationFailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :authorization_fails, :integer, default: 0
  end
end
