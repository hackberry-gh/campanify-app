class CreatePagesWidgets < ActiveRecord::Migration
  def up
    create_table :pages_widgets, :id => false do |t|
      t.integer :page_id
      t.integer :widget_id
    end
    add_index :pages_widgets, [:page_id,:widget_id] 
  end

  def down
    drop_table :pages_widgets
  end
end
