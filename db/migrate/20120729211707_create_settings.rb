class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.text :data
    end
  end
end
