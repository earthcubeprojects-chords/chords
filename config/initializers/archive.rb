# Read in and parse the config/archive.yml configuration file
ARCHIVE_CONFIG = Rails.application.config_for(:archive)
Rails.application.config.x.archive = ARCHIVE_CONFIG
