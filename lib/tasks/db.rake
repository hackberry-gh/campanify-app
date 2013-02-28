namespace :db do
  desc "reset and seed db"
  task :erase_and_rewind do 
    system "rake db:drop"
    system "rake db:create"
    system "rake db:migrate"
    system "rake db:seed:original"
    system "rake db:seed:themes_default_install"
    system "bundle exec rake db:test:prepare"
  end
end