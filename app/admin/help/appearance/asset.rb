ActiveAdmin.register_page "Asset", :namespace => "help" do
  menu :label => "Asset", :parent => "Appearance"
  content do
    render "index"
  end
end