namespace :db do
  desc "reset and seed db"
  task :erase_and_rewind do 
    system "bundle exec rake db:drop"
    system "bundle exec rake db:create"
    system "bundle exec rake db:migrate"
    system "bundle exec rake db:seed:original"
    system "bundle exec rake db:seed:themes_default_install"
    system "bundle exec rake db:test:prepare"
  end
end