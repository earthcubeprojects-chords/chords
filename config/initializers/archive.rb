# Read in and parse the config/archive.yml configuration file
archive_config_file = "#{Rails.root.to_s}/config/archive.yml"
if File.exists?(archive_config_file)
  Rails.application.config.x.archive = Rails.application.config_for(:archive)
end