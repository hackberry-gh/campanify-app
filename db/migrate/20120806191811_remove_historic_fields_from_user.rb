class RemoveHistoricFieldsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :visits
    remove_column :users, :recruits
  end

  def down
    add_column :users, :recruits, :text
    add_column :users, :visits, :text
  end
end
