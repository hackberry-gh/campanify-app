ActiveAdmin.register Appearance::Asset do
  menu :parent => "Appearance"
  index do
    column :filename
    default_actions
  end  
  form do |f|
    f.inputs do
      f.input :filename, :hint => "example.js"
      f.input :body, :as => :code, :mode => "asset"
      f.input :content_type, :as => :select, :collection => Appearance::Asset::VALID_TYPES
    end
    f.buttons
  end
end