namespace :campanify do
  desc "campanify setup script, should run immediately after first git push, this rake should run on git repository host, probably campanify.it server or local machine"
  task :setup => :environment do |t, args|
    system "#{Rails.root}/install.sh"

    Hash[File.open(".env").read.split("\n").map{|v| v.split("=")}].each do |k,v|
      puts("heroku config:add #{k}=#{v}")
    end
    
    system('bundle exec heroku run rake db:migrate --account campanify_tech')
    system('bundle exec heroku run rake db:seed --account campanify_tech')
  end
end