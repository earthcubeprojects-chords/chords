source 'https://rubygems.org'

gem 'rails', '~> 5.2.4'
# gem 'rails', '~> 5.2.4'
gem 'mysql2', '~> 0.5'
gem 'influxdb', '~> 0.6'
gem "influxer", "~> 1.1"

gem 'uglifier', '~> 4.1'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails', '~> 4.3'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem 'sass-rails', '~> 5.0'
gem 'underscore-rails'

gem 'jbuilder', '~> 2.7'
gem 'sdoc', '~> 0.4.0', group: :doc
gem "highcharts-rails"
gem 'rails4-autocomplete'

gem 'devise', '~> 4.7.1'
gem 'cancancan', '~> 2.3'

gem 'sys-uptime'
gem 'ffi', '~> 1.9.25'
gem 'loofah', '>= 2.3.1'
gem 'rack', '>= 2.0.8'

gem 'mini_portile2'
gem 'whenever', '~> 0.9.7', :require => false
gem 'rubyzip', '~> 1.3.0'


gem 'bootsnap', require: false

# Specific gem versions based on Dependabot security scans
# Updated 9/28/2020
gem 'nokogiri',             '~> 1.13.9'
gem 'websocket-extensions', '~> 0.1.5'
gem 'json',                 '~> 1.8.6'

# sdoc has a dependency of json ~ 1.7.7
# gem 'json',                 '~> 2.3.0'

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
  gem 'email_spec'
  gem 'rails-controller-testing'
  gem 'timecop'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem 'rubocop', '~> 0.52.1', require: false
end

group :production do
  # Use Unicorn as the app server
  gem 'unicorn-rails'
end
