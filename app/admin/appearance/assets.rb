ActiveAdmin.register Appearance::Asset do
  
  controller.authorize_resource :class => Appearance::Asset
    
  menu :parent => "Appearance", :priority => 1, :if => proc{ can?(:read, Appearance::Asset) }
  
  index do
    column :filename
    column :content_type    
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
