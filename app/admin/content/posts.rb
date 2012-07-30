ActiveAdmin.register Content::Post do
  menu :parent => "Content"
  scope :published

  index do
    column :user
    column :title
    column :published do |content_post|
      content_post.published?
    end
    default_actions
  end
  
  form :partial => "form"
end
