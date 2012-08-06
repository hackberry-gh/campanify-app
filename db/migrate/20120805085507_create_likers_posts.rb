class CreateLikersPosts < ActiveRecord::Migration
  def up
    create_table :likers_posts, :id => false do |t|
      t.integer :liker_id
      t.integer :post_id
    end
    add_index :likers_posts, [:liker_id,:post_id] 
  end

  def down
    drop_table :likers_posts
  end
end
