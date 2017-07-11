


# Read in and parse the influxdb config file
file_path = "#{Rails.root.to_s}/config/influxdb.yml"

INFLUXDB_CONFIG = YAML.load(ERB.new(File.new(file_path).read).result)[Rails.env]

  
