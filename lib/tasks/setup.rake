namespace :campanify do
  task :setup => :environment do
    system('heroku run rake db:migrate')
    system('heroku run rake db:seed')        
  end
end