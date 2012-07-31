ActiveAdmin.register Content::Widget do
  menu :parent => "Content"

  index do
    column :title
    column :position
    default_actions
  end
  
  form do |f|
    f.globalize_inputs :translations do |lf|
      lf.inputs :title, :body, :locale do
        lf.input :title
        lf.input :body, :as => :code, :mode => "html"

        lf.input :locale, :as => :hidden
      end
    end
    f.inputs do
      f.input :position, :as => :number
    end
    f.buttons
  end
end
