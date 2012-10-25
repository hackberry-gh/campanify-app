ActiveAdmin.register_page "Administrator", :namespace => "help" do
  menu :label => "Administrator", :parent => "Admin"
  content do
    render "index"
  end
end