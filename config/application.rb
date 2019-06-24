require_relative 'boot'

require 'rails/all'
require 'csv'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChordTestbed
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.timezone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    require "#{Rails.root}/app/models/tspoint.rb"

    # Leave false for now and add validations to these relationships, setting defaults via migration when it's done
    # If this is set to true before that, weird errors can happen when trying to update objects without those relationships set
    config.active_record.belongs_to_required_by_default = false

    config.autoload_paths += %W(#{config.root}/lib)

    # To get rid of console complaints in docker deployment
    #config.web_console.whitelisted_ips = '192.168.0.0/16'

    config.generators do |g|
        g.test_framework :rspec
        g.integration_tool :rspec
    end
  end
end
