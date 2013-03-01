class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.string  :slug
      t.integer :sequence
      t.text :meta

      t.timestamps
    end
    add_index :levels, :slug
    add_index :levels, :sequence
  end
end
