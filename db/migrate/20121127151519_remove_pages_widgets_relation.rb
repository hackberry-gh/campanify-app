class RemovePagesWidgetsRelation < ActiveRecord::Migration
  def up
    drop_table :pages_widgets
    remove_column :content_widgets, :position
    add_index :content_widgets, :slug
  end

  def down
    create_table :pages_widgets, :id => false do |t|
      t.integer :page_id
      t.integer :widget_id
    end
    add_column :content_widgets, :position    
    remove_index :content_widgets, :slug    
  end
end
