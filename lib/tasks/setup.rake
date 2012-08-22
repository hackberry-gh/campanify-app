namespace :campanify do
  task :setup => :environment do
    system('bundle exec heroku run rake db:migrate')
    system('bundle exec heroku run rake db:seed')        
  end
end