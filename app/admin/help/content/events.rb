ActiveAdmin.register_page "Event", :namespace => "docs" do
  menu :label => "Event", :parent => "Content"
  content do
    render "index"
  end
end