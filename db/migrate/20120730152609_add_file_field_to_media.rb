class AddFileFieldToMedia < ActiveRecord::Migration
  def change
    add_column :content_media, :file, :string
  end
end
