ActiveAdmin.register_page "Template", :namespace => "docs" do
  menu :label => "Template", :parent => "Appearance"
  content do
    render "index"
  end
end