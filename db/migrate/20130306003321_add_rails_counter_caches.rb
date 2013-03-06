class AddRailsCounterCaches < ActiveRecord::Migration
  def up
  	add_column :users, :posts_count, :integer, :default => 0
    add_column :users, :media_count, :integer, :default => 0

  	User.reset_column_information
    User.all.each do |u|
      User.update_counters u.id, :posts_count => u.posts.length, :media_count => u.media.length
    end
  end

  def down
  	remove_column :users, :posts_count
    remove_column :users, :media_count
  end
end
