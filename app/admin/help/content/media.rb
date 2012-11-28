ActiveAdmin.register_page "Media", :namespace => "docs" do
  menu :label => "Media", :parent => "Content"
  content do
    render "index"
  end
end