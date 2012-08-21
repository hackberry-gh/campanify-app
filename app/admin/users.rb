ActiveAdmin.register User do
  actions :index, :show, :edit, :update, :destroy
  index do
    column :full_name
    column :email
    column :language
    column :country
    column :branch  
    column :popularity
    default_actions          
  end
end
