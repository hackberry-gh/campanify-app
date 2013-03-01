ActiveAdmin.register_page "User", :namespace => "docs" do
  menu :label => "Supporter"
  content do
    render "index"
  end
end