class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :full_name, :string
    add_column :users, :display_name, :string
    add_column :users, :birth_year, :string
    add_column :users, :birth_date, :string
    add_column :users, :country, :string
    add_column :users, :region, :string
    add_column :users, :city, :string
    add_column :users, :address, :string
    add_column :users, :post_code, :string
    add_column :users, :phone, :string
    add_column :users, :mobile_phone, :string
    add_column :users, :branch, :string
    add_column :users, :language, :string
    add_column :users, :send_updates, :boolean
    add_column :users, :legal_aggrement, :boolean
    add_column :users, :visits, :text
    add_column :users, :recruits, :text
    add_index :users, :country
    add_index :users, :branch
  end
end
