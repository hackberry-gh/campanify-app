ActiveAdmin.register Content::Widget do
  controller.authorize_resource :class => Content::Widget 
  menu :parent => "Content", :priority => 2, :if => proc{ can?(:read, Content::Widget) }

  index do
    selectable_column
    column :title
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
    f.buttons
  end
end
