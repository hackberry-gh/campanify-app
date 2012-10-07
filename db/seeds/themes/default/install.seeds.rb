# SETTINGS
Settings.instance.data = YAML::load(File.read("#{Rails.root}/db/seeds/themes/default/settings.yml"))[Rails.env]  	    
Settings.instance.save!

# TRANSLATIONS
I18n.backend.backends[1].load_translations
translations = I18n.backend.backends[1].send(:translations)

translatebles = %(errors activerecord helpers flash devise views sharing html user_mailer language)

I18n.available_locales.each do |locale|      
  translations[:en].each do |key,value|
    if translatebles.include?(key.to_s.split(".").first)
      I18n.backend.store_translations(locale.to_s,{key => value}, :escape => false)
    end
  end
end
# TRANSLATIONS END

# TEMPLATES
Appearance::Template.destroy_all
Dir["#{Rails.root}/db/seeds/themes/default/views/**/*"].delete_if{|f| !f.include?(".")}.each do |file|
  unless file.include?("admin")
    body = File.read(file)
    file_parts = file.split("/")
    path, format, handler = file_parts.last.split(".")
    partial = path.include?("_")
    file_parts.pop
    path = "#{file_parts.join("/")}/#{path}".gsub("#{Rails.root}/db/seeds/themes/default/views/","")
    temp = Appearance::Template.create(:body => body, :format => format, 
    :handler => handler, :locale => "en", 
    :partial => partial, :path => path)                            
  end
end
# TEMPLATES END

# ASSETS
Appearance::Asset.destroy_all
Dir["#{Rails.root}/db/seeds/themes/default/assets/**/*"].
delete_if{|f| !f.include?(".")}.each do |file|
  body = File.read(file)
  file_parts = file.split("/")
  filename = file_parts.last
  content_type = Appearance::Asset::VALID_TYPES[file_parts.last.split(".").last.to_sym]
  asset = Appearance::Asset.create(:body => body, :content_type => content_type, :filename => filename)                            
end
# ASSETS END


# CONTENT
user = User.create(first_name: "John", last_name: "Doe", email: "johndoe@campanify.it")

home = Content::Page.create(title: "Home", body: File.read("#{Rails.root}/db/seeds/themes/default/pages/home.html"))
about = Content::Page.create(title: "About", body: File.read("#{Rails.root}/db/seeds/themes/default/pages/about.html"))
thank_you = Content::Page.create(title: "Thank You", body: File.read("#{Rails.root}/db/seeds/themes/default/pages/thank-you.html"))
user_form = Content::Widget.create(title: "User Form", body: File.read("#{Rails.root}/db/seeds/themes/default/widgets/user-form.html.erb"))
social_sharing = Content::Widget.create(title: "Social Sharing", body: File.read("#{Rails.root}/db/seeds/themes/default/widgets/social-sharing.html.erb"))
flexi_slider = Content::Widget.create(title: "Flex Slider", body: File.read("#{Rails.root}/db/seeds/themes/default/widgets/flex-slider.html.erb"))

home.widgets << user_form if home.persisted?
thank_you.widgets << social_sharing if thank_you.persisted?
# don't add to widgets inline rendering
# about.widgets << flexi_slider

sample_post = Content::Post.new(title: "Sample Post", body: File.read("#{Rails.root}/db/seeds/themes/default/posts/sample.md"))
sample_post.user = user
sample_post.save if user.persisted?

sample_event = Content::Event.create(
name: "Campanify Launch Party", 
description: "We are proud to launch our baby Campanify 1.0",
start_time: Time.now, 
location: "Whitecube Gallery", 
venue: {street: "Hoxton Square", city: "London", state: "England", zip: "N1 6PB", 
  country: "United Kingdom", latitude: "51.52725461288175", longitude: "-0.0813526878051789" },
privacy: "OPEN"  
)
# CONTENT END