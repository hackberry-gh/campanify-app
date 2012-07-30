ActiveAdmin.register Content::Media do
  menu :parent => "Content"

  index do
    column :title
    column :media do |content_medium|
      if content_medium.link.present?
        link_to content_medium.link, content_medium.link, target: "blank"
      else
        if %w(jpg jpeg gif png).include?(content_medium.file.url.split(".").last)
          image_tag content_medium.file.thumb
        else
          content_medium.file
        end
      end
    end
    column :versions do |content_medium|
      Settings.media["thumbs"].map{|t| t["name"]}.join(",")
    end
    default_actions
  end
  form :partial => "form"
end
