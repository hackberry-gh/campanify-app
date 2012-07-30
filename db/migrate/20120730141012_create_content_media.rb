class CreateContentMedia < ActiveRecord::Migration
  def change
    create_table :content_media do |t|
      t.string  :title
      t.string  :description

      t.timestamps
    end
  end
end
