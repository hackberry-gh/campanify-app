class CreateAppearanceAssets < ActiveRecord::Migration
  def change
    create_table :appearance_assets do |t|

      t.timestamps
    end
  end
end
