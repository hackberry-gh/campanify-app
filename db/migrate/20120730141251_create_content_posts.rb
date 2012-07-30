class CreateContentPosts < ActiveRecord::Migration
  def change
    create_table :content_posts do |t|
      t.string  :title
      t.string  :slug      
      t.text    :body
      t.datetime    :published_at
      t.integer :user_id

      t.timestamps
    end
    add_index :content_posts, [:slug, :published_at, :user_id]
  end
end
