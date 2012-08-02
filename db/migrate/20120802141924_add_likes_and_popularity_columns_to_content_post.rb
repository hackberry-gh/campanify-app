class AddLikesAndPopularityColumnsToContentPost < ActiveRecord::Migration
  def change
    add_column :content_posts, :likes, :text
    add_column :content_posts, :popularity, :integer, :default => 0
  end
end
