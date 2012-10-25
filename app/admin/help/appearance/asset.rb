ActiveAdmin.register_page "Asset", :namespace => "docs" do
  menu :label => "Asset", :parent => "Appearance"
  content do
    render "index"
  end
end