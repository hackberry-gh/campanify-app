ActiveAdmin.register_page "Administrator", :namespace => "docs" do
  menu :label => "Administrator", :parent => "Admin"
  content do
    render "index"
  end
end