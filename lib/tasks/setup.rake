namespace :campanify do
  desc "campanify setup script, should run immediately after first git push, this rake should run on git repository host, probably campanify.it server or local machine"
  task :setup, [:name, :slug, :admin_email, :admin_name, :admin_password] => :environment do |t, args|

    file_name = "#{Rails.root}/db/seeds.rb"
    content = File.read(file_name)
    content = content.gsub(/\$name/, args[:name])
    content = content.gsub(/\$slug/, args[:slug])
    content = content.gsub(/\$admin_email/, args[:admin_email])
    content = content.gsub(/\$admin_full_name/, args[:admin_name])        
    content = content.gsub(/\$admin_password/, args[:admin_password])            

    File.open(file_name, "w") {|file| file.write seeds}
    
    file_name = "#{Rails.root}/install.sh"
    content = File.read(file_name)
    content = content.gsub(/\$name/, args[:name])
    content = content.gsub(/\$slug/, args[:slug])

    File.open(file_name, "w") {|file| file.write seeds}
    
    return {error: app["name"]} unless system "./#{app_dir}/install.sh"

    Hash[File.open(".env").read.split("\n").map{|v| v.split("=")}].each do |k,v|
      puts("heroku config:add #{k}=#{v}")
    end
    system('bundle exec heroku run rake db:migrate --account campanify_tech')
    system('bundle exec heroku run rake db:seed --account campanify_tech')        
  end
end