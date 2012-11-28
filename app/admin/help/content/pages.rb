ActiveAdmin.register_page "Page", :namespace => "docs" do
  menu :label => "Page", :parent => "Content"
  content do
    render "index"
  end
end