ActiveAdmin.register_page "Campaign", :namespace => "help" do
  menu :label => "Campaign", :parent => "Admin"
  content do
    render "index"
  end
end