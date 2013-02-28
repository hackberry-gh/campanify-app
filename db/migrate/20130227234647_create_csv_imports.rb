class CreateCsvImports < ActiveRecord::Migration
  def change
    create_table :csv_imports do |t|
      t.string :filename
      t.text :results

      t.timestamps
    end
  end
end
