class AddUserIdToContentMedia < ActiveRecord::Migration
  def change
    add_column :content_media, :user_id, :integer
    add_index :content_media, :user_id
  end
end
