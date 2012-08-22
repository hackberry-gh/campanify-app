campaign = Campaign.create(name: "Campanify Base", slug:"campanify-base")
campaign.setup

admin = Administrator.create!(email: 'admin@campanify.it', full_name: "Admin", role: "root")
admin.password = "passw0rd"
admin.password_confirmation = "passw0rd"
admin.save!

user = User.create!(first_name: "John", last_name: "Doe", email: "johndoe@campanify.it")

home = Content::Page.create!(title: "Home", body: File.read("#{Rails.root}/db/seeds/pages/home.html"))
about = Content::Page.create!(title: "About", body: File.read("#{Rails.root}/db/seeds/pages/about.html"))
thank_you = Content::Page.create!(title: "Thank You", body: File.read("#{Rails.root}/db/seeds/pages/thank-you.html"))
user_form = Content::Widget.create!(title: "User Form", body: File.read("#{Rails.root}/db/seeds/widgets/user-form.html.erb"))
social_sharing = Content::Widget.create!(title: "Social Sharing", body: File.read("#{Rails.root}/db/seeds/widgets/social-sharing.html.erb"))

home.widgets << user_form
thank_you.widgets << social_sharing

sample_post = Content::Post.create!(title: "Sample Post", body: File.read("#{Rails.root}/db/seeds/posts/sample.md", user_id: user.id))