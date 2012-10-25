ActiveAdmin.register_page "Settings", :namespace => "help" do
  menu :label => "Settings", :parent => "Admin"
  content do
    render "index"
  end
end