ActiveAdmin.register_page "User", :namespace => "docs" do
  menu :label => "User"
  content do
    render "index"
  end
end