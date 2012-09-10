ActiveAdmin.register Content::Media do
  controller.authorize_resource :class => Content::Media
  menu :parent => "Content", :priority => 5, :if => proc{ can?(:read, Content::Media) }

  index do
    column :title
    column :media do |content_medium|
      if %w(jpg jpeg gif png).include?(content_medium.file.url.split(".").last)
        image_tag content_medium.file.thumb
      else
        content_medium.file
      end
    end
    column :versions do |content_medium|
      Settings.media["versions"].map{|t| t["name"]}.join(",")
    end
    default_actions
  end
  
  form do |f|
    f.globalize_inputs :translations do |lf|
      lf.inputs :title, :body, :locale do
        lf.input :title
        lf.input :description, :as => :text

        lf.input :locale, :as => :hidden
      end
    end
    f.inputs do
      f.input :file, :as => :file
    end
    f.buttons
  end
  
  
  show do |content_medium|
    attributes_table do
      row :title
      row :description        
      row :media do
        if %w(jpg jpeg gif png).include?(content_medium.file.url.split(".").last)
          image_tag content_medium.file, :style => "width:100%"
        else
          content_medium.file
        end
      end
      row :urls do
        span{"<strong>original</strong>: #{content_medium.file}<br/>".html_safe}
        Settings.media["versions"].map{|t| span{"<strong>#{t["name"]}</strong>: #{content_medium.file.send(t["name"].to_sym)}".html_safe}}.join("<br/>").html_safe
      end
    end
    active_admin_comments
  end

end
