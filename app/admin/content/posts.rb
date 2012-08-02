ActiveAdmin.register Content::Post do
  menu :parent => "Content"
  scope :published
  scope :unpublished
  member_action :unpublish do
    Content::Post.find(params[:id]).unpublish!
    redirect_to admin_content_posts_path, :notice => "Post has been unpublished successfully"    
  end
  
  member_action :publish do
    Content::Post.find(params[:id]).publish! 
    redirect_to admin_content_posts_path, :notice => "Post has been published successfully"
  end
  
  action_item :only => [:edit, :show] do
    publish_status = content_post.published? ? "unpublish" : "publish"
    link_to publish_status.titleize, self.send("#{publish_status}_admin_content_post_path".to_sym, content_post.id)
  end

  index do
    column :user do |content_post|
      link_to content_post.user.email, admin_user_path(content_post.user) if content_post.user
    end
    column :title
    column :published do |content_post|
      publish_status = content_post.published? ? "published" : "unpublished"      
      span(publish_status.titleize,:class => "status #{publish_status}")
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
      f.input :user, :as => :string, :input_html => {:disabled => true, :value => f.object.user.email}
    end
    f.buttons
  end
  
end
