class AddCampanifyIdToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :campanify_id, :integer
    add_index :campaigns, :campanify_id    
  end
end
