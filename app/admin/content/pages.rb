ActiveAdmin.register Content::Page do
  menu :parent => "Content"
  scope :published

  index do
    column :title
    column :published do |content_page|
      content_page.published?
    end
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
      f.input :published_at, :as => :datetime
      f.input :widgets, :as => :check_boxes
    end
    f.buttons
  end
  
end
