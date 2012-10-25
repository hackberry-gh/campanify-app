ActiveAdmin.register_page "Welcome", :namespace => "docs" do
  menu :label => "Welcome", :priority => 1
  content do
    h2 "Welcome Campanify Documentation"
    para "Campanify is still beta and some part of this documentation can be missing."
    para "Please feel free to contact <a href=\"mailto:support@campanify.it\">support@campanify.it</a> for any kind of support".html_safe
  end
end