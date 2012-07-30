class CreateContentPages < ActiveRecord::Migration
  def change
    create_table :content_pages do |t|
      t.string :title
      t.string :slug      
      t.text :body
      t.datetime :published_at

      t.timestamps
    end
    add_index :content_pages, [:slug, :published_at]
  end
end
