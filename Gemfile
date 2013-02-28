source 'https://rubygems.org'

gem 'rails', 												'3.2.11'
gem 'pg'
gem 'unicorn'
gem 'acts_as_singleton'
gem 'i18n-active_record',
      :git => 'git://github.com/svenfuchs/i18n-active_record.git',
      :branch => 'rails-3.2',
      :require => 'i18n/active_record'
gem "yui-compressor", 							"~> 0.9.6"
gem "devise", 											"~> 2.1.2"
gem 'globalize3', 
			:git => "git://github.com/svenfuchs/globalize3.git"
gem 'routing-filter'			
gem 'rmagick',											'~> 2.13.1'			
gem 'carrierwave', :git => "git://github.com/jnicklas/carrierwave.git"
gem "fog" 													
gem 'koala'												
gem "httparty", 										"~> 0.8.3"
gem "delayed_job", 									"~> 3.0.3"  
gem "delayed_job_active_record"
gem 'geoip'
gem 'cancan'
gem 'heroku-api'
gem 'heroku',												'~> 2.32.8'
gem 'activeadmin',									'~> 0.5.1'
gem "omniauth-facebook"
gem 'redcarpet'
gem 'i18n_country_select', 
			:git => 'git://github.com/lemmycaution/i18n_country_select.git'
gem 'ox'
gem 'newrelic_rpm'
gem 'memcachier'
gem 'dalli'
gem 'seedbank'
gem 'timecop'
gem 'devise_invitable'
gem 'quiet_assets'

	
group :assets do
  gem 'sass-rails',   							'~> 3.2.3'
  gem 'coffee-rails', 							'~> 3.2.1'
  gem 'uglifier', 									'>= 1.0.3'
  gem 'asset_sync'
 	gem "turbo-sprockets-rails3", 		"~> 0.3.6"
end

gem 'jquery-rails'

group :development do
	gem 'thin'
	gem 'hirb'
	gem 'wirble'
end

group :test do
	gem 'database_cleaner', 					'~> 0.8.0'
end

group :test, :development do
	gem 'rspec-rails', 								'~> 2.11.0'
	gem 'capybara', 									'~> 1.1.2'
end
