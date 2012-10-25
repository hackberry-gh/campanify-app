ActiveAdmin.register_page "Settings", :namespace => "docs" do
  menu :label => "Settings", :parent => "Admin"
  content do
    render "index"
  end
end