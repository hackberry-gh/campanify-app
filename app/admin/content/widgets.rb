ActiveAdmin.register Content::Widget do
  menu :parent => "Content"

  index do
    column :title
    column :position
    default_actions
  end
  
  form :partial => "form"
end
