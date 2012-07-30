class CreateAppearanceTemplates < ActiveRecord::Migration
  def change
    create_table :appearance_templates do |t|
      t.text :body
      t.string :path
      t.string :locale
      t.string :format
      t.string :handler
      t.boolean :partial

      t.timestamps
    end
    add_index :appearance_templates, [:path, :locale, :format, :handler, :partial], name: "index_appearance_templates", unique: true
  end
end
