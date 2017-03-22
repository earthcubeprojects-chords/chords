# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Registre geojson and geocsv as mime types
Mime::Type.register "text/plain", :geojson
Mime::Type.register "text/plain", :geocsv
