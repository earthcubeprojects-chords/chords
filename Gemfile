source 'https://rubygems.org'

gem 'rails', '4.2.10'
gem 'mysql2', '~> 0.3.19'
gem 'influxdb', '~> 0.5.3'
gem "influxer", "~> 1.1"

gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem 'sass-rails', '~> 5.0'

gem 'markerclustererplus-rails'
gem 'underscore-rails'

gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem "best_in_place"
gem "highcharts-rails"
gem 'rails4-autocomplete'

gem 'devise'
gem 'cancancan', '~> 2.0.0'

gem 'sys-uptime'

gem 'mini_portile2'
gem 'whenever', "~>0.9.7", :require => false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'spring'

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

  gem 'rubocop', '~> 0.52.1', require: false
end

group :production do
  # Use Unicorn as the app server
  gem 'unicorn-rails'
end
