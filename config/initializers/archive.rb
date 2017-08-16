# Read in and parse the config/archive.yml configuration file
archive_config_file = "#{Rails.root.to_s}/config/archive.yml"
if File.exists?(archive_config_file)
  encrypted_config = Rails.application.config_for(:archive)

  crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)      

  Rails.application.config.x.archive = Hash.new

  Rails.application.config.x.archive['username'] = crypt.decrypt_and_verify(encrypted_config['username'])
  Rails.application.config.x.archive['password'] = crypt.decrypt_and_verify(encrypted_config['password'])
  Rails.application.config.x.archive['base_url'] = crypt.decrypt_and_verify(encrypted_config['base_url'])
end