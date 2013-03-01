ActiveAdmin.register Level do
	controller.authorize_resource  
  menu :parent => "Supporters", :if => proc{ can?(:read, Level) }
  
  index do
    selectable_column
    column :slug
    column :sequence
    default_actions          
  end
  form do |f|
    f.inputs do
      f.input :slug
      f.input :sequence
      f.input :meta, as: "settings"
    end
    f.buttons
  end
end
