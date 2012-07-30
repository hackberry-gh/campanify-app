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
  form :partial => "form"
  
end
