ActiveAdmin.register Content::Post do
  menu :parent => "Content"
  scope :published

  index do
    column :user do |content_post|
      link_to content_post.user.email, admin_user_path(content_post.user)
    end
    column :title
    column :published do |content_post|
      content_post.published?
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
      f.input :user
    end
    f.buttons
  end
  
end
