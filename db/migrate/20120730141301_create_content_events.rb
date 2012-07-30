class CreateContentEvents < ActiveRecord::Migration
  def change
    create_table :content_events do |t|
      t.string  :fb_id
      t.string  :name
      t.string  :slug      
      t.text    :description
      t.time    :start_time
      t.time    :end_time
      t.string  :location
      t.text    :venue
      t.string  :privacy
      t.string  :parent

      t.timestamps
    end
    add_index :content_events, :slug
  end
end
