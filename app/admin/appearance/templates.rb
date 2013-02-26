ActiveAdmin.register Appearance::Template do
  
  scope :partials

  controller.authorize_resource :class => Appearance::Template
    
  menu :parent => "Appearance", :priority => 2, :if => proc{ can?(:read, Appearance::Template) }
  
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
