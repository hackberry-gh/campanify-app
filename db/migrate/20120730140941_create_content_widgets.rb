class CreateContentWidgets < ActiveRecord::Migration
  def change
    create_table :content_widgets do |t|
      t.string  :title
      t.text    :body
      t.integer :position

      t.timestamps
    end
    add_index :content_widgets, [:id, :position]
  end
end
