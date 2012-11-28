ActiveAdmin.register_page "Post", :namespace => "docs" do
  menu :label => "Post", :parent => "Content"
  content do
    render "index"
  end
end