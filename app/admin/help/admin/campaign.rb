ActiveAdmin.register_page "Campaign", :namespace => "docs" do
  menu :label => "Campaign", :parent => "Admin"
  content do
    render "index"
  end
end