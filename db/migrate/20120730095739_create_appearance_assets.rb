class CreateAppearanceAssets < ActiveRecord::Migration
  def change
    create_table :appearance_assets do |t|
      t.string :filename
      t.text :body
      t.string :content_type

      t.timestamps
    end
    add_index :appearance_assets, [:content_type, :filename], uniq: true
  end
end
