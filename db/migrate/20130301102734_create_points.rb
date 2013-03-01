class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :user_id
      t.integer :level_id
      t.integer :amount
      t.string :source_type
      t.integer :source_id
      t.string :action

      t.timestamps
    end
    add_index :points, :user_id
    add_index :points, :level_id
    add_index :points, :source_id
    add_index :points, :action
  end
end
