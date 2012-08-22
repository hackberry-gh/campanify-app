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
  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :full_name
      f.input :display_name
      f.input :birth_year
      f.input :birth_date
      f.input :country, :as => :string
      f.input :region
      f.input :city
      f.input :address
      f.input :post_code
      f.input :phone
      f.input :mobile_phone
      f.input :branch
      f.input :language
      f.input :send_updates
      f.input :legal_aggrement
      f.input :provider
      f.input :uid
      f.input :avatar, :as => :file,
              :hint => f.object.avatar ? image_tag(f.object.avatar.thumb) : ""
    end
    f.buttons
  end
end
