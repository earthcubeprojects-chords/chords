source 'https://rubygems.org'

gem 'rails', '4.2.10'
gem 'mysql2', '~> 0.3.19'
gem 'influxdb'
gem "influxer", "~>0.5.0"

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem 'sass-rails', '~> 5.0'

# Google Maps For Rails and dependencies
gem 'gmaps4rails'

# Javascript helpers
gem 'underscore-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem "best_in_place"
gem "highcharts-rails"
gem 'rails4-autocomplete'

gem 'devise'
gem 'access-granted'

gem 'sys-uptime'

gem 'mini_portile2'
gem 'whenever', "~>0.9.7", :require => false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # layout
  gem 'rails_layout'
  gem 'puma'

  gem "factory_bot_rails"
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'

  gem 'database_cleaner'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :production do
  # Use Unicorn as the app server
  gem 'unicorn-rails'
end
