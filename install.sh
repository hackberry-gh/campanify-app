cd $app_dir
heroku accounts:set campanify_tech
rvm getset use campanify
git remote rm heroku
git remote add heroku git@heroku.campanify_tech:$slug.git           
git commit -am 'seeds.rb updated'
git push heroku master
bundle exec rake campanify:setup