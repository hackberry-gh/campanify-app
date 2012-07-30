ActiveAdmin.register User do
  actions :index, :show
  index do
    column :full_name
    column :email
    column :language
    column :country
    column :branch            
  end
end
