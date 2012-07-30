class CreateAppearanceTemplates < ActiveRecord::Migration
  def change
    create_table :appearance_templates do |t|

      t.timestamps
    end
  end
end
