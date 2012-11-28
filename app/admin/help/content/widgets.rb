ActiveAdmin.register_page "Widget", :namespace => "docs" do
  menu :label => "Widget", :parent => "Content"
  content do
    render "index"
  end
end