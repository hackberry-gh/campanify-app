class AddTwitterFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :tw_screen_name, :string
    add_column :users, :tw_token, :string
    add_column :users, :tw_secret, :string
  end
end
