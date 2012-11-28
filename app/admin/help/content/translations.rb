ActiveAdmin.register_page "Translation", :namespace => "docs" do
  menu :label => "Translation", :parent => "Content"
  content do
    render "index"
  end
end