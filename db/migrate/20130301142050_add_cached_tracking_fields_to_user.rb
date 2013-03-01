class AddCachedTrackingFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :cached_uniq_visits, :integer
    add_column :users, :cached_uniq_recruits, :integer
  end
end
