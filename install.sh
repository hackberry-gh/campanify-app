heroku create campanify-base
git push heroku history-on-table:master
bundle exec rake campanify:setup