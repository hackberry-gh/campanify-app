class AddPopularityColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :popularity, :integer, :default => 0
  end
end
