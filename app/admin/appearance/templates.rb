ActiveAdmin.register Appearance::Template do
  menu :parent => "Appearance"
  index do
    column :path
    column :format
    column :handler
    column :locale    
    column :partial            
    default_actions
  end
  form do |f|
    f.inputs do
      f.input :body, :as => :code, :mode => "html"
      f.input :path
      f.input :format
      f.input :handler
      f.input :locale, :as => :select, :collection => I18n.available_locales
      f.input :partial, :as => :boolean
    end
    f.buttons
  end
end
