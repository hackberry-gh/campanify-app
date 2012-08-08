class RemoveHistoricFieldsFromContentPost < ActiveRecord::Migration
  def up
    remove_column :content_posts, :likes
  end

  def down
    add_column :content_posts, :likes, :text
  end
end
