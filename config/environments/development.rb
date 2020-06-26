Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  # Also needed for the CHORDS code that doesn't match the rails framework,
  # such as tspoint.rb
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true



  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end




  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # email config
  from_email = if Rails.application.config.action_mailer.smtp_settings
                 Rails.application.config.action_mailer.smtp_settings[:user_name]
               else
                 'admin@chordsrt.com'
               end

  config.action_mailer.default_options = {from: from_email}
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address:               ENV['CHORDS_EMAIL_SERVER'],
    port:                  ENV['CHORDS_EMAIL_PORT'],
    user_name:             ENV['CHORDS_EMAIL_ADDRESS'],
    password:              ENV['CHORDS_EMAIL_PASSWORD'],
    authentication:        'plain',
    enable_starttls_auto:  true
  }


  # Rotate log files
  config.logger = Logger.new(config.paths['log'].first, 10, 25.megabytes)

  # Port that Grafana is using, normally configured with enviroment variables
  config.grafana_http_port = ENV['GRAFANA_HTTP_PORT'] || 3001

  # SSL Settings
  # default_url_options is required for the correct http/https prefix to be applied to rails generated paths and urls
  if (! ENV['SSL_ENABLED'].blank? && ENV['SSL_ENABLED'] == 'true') 
    config.action_controller.default_url_options= {:protocol => 'https'}
  end
  
end
