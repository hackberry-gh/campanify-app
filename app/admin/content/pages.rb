ActiveAdmin.register Content::Page do
  controller.authorize_resource :class => Content::Media
  menu :parent => "Content", :priority => 1, :if => proc{ can?(:read, Content::Page) }  
  scope :published
  scope :unpublished
  member_action :unpublish do
    Content::Page.find(params[:id]).unpublish!
    redirect_to admin_content_pages_path, :notice => "Page has been unpublished successfully"    
  end
  
  member_action :publish do
    Content::Page.find(params[:id]).publish! 
    redirect_to admin_content_pages_path, :notice => "Page has been published successfully"
  end
  
  action_item :only => [:edit, :show] do
    publish_status = content_page.published? ? "unpublish" : "publish"
    link_to publish_status.titleize, self.send("#{publish_status}_admin_content_page_path".to_sym, content_page.id)
  end

  index do
    column :title
    column :published do |content_page|
      publish_status = content_page.published? ? "published" : "unpublished"      
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
      row :published_at
      row :created_at      
      row :updated_at            
    end
    active_admin_comments
  end
  
end
