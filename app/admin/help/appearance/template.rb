ActiveAdmin.register_page "Template", :namespace => "help" do
  menu :label => "Template", :parent => "Appearance"
  content do
    render "index"
  end
end