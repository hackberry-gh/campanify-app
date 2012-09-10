class AddMetaFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :meta, :text
  end
end
