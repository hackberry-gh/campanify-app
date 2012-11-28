ActiveAdmin.register Content::Post do
  controller.authorize_resource :class => Content::Post  
  menu :parent => "Content", :priority => 3, :if => proc{ can?(:read, Content::Post) }  
  scope :published
  scope :unpublished
  actions :index, :show, :edit, :update, :destroy
  
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

    f.inputs  do
      f.input :title
      f.input :body, :as => :code, :mode => "markdown"
    end
      
    f.inputs do
      f.input :published_at, :as => :datetime
      f.input :user, :as => :string, :input_html => {:disabled => true, :value => f.object.user.email}
    end
    
    f.buttons
  end
  
  show do |page|
    attributes_table do
      row :title
      row :slug      
      row :body do
        content_tag :pre, "#{page.body}"
      end
      row :user
      row :popularity      
      row :published_at
      row :created_at      
      row :updated_at            
    end
    active_admin_comments
  end
  
end
