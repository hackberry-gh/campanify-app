ActiveAdmin.register Content::Media do
  menu :parent => "Content"

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
      Settings.media["thumbs"].map{|t| t["name"]}.join(",")
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
end
