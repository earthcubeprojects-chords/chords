require 'influxdb'
require 'json'

class TSDBClient

  def initialize(*args)
    # 
    # new(databasename, {InfluxDB options})  # Connect and acces named database
    #   or
    # new({InfluxDB options})  # Connect without a specific database identified (unless database: is specified)
    #
    # See influxdb-ruby client.rb for valid hash keys in the options.
    
    # Set default options.
    options = {host: 'influxdb', time_precision: 'ms', retry: 3}

    # Merge the user suppied options
    opts = args.last.is_a?(Hash) ? args.last : {}
    opts[:database] = args.first if args.first.is_a? String
    options.merge!(opts)
    
    # Create the client. 
    @db = InfluxDB::Client.new(options)
    
    # Try to contact the database. An exception will be raised on failure
    @db.ping
    
    # If the named database does not exist, create it
    if options.key?(:database) then
      exists = false
      databases = list_databases
      databases.each do |d|
        if d["name"] == config.database then
          exists = true
        end
      end    
      if !exists then
        self.create_database
      end
    end
    
  end
  
  def query(q)
    return @db.query(q)
  end
  
  def write(site, name, time, value)
    q_result = @db.query
    return q_result
  end
  
  def write_point(data) 
    w_result = @db.write_point(data)
    return w_result
  end

  def write_points(data) 
    w_result = @db.write_points(data)
    return w_result
  end

  def list_databases
    return @db.list_databases
  end

  def create_database
    @db.create_database(config.database)
    print "Database #{config.database} created\n"
  end
  
  def config
    @db.config
  end

  def self.ping(host, retries = 3)
    db = InfluxDB::Client.new(host: host, retry: retries)
    return db.ping
  end

  def self.version(host, retries = 3)
    db = InfluxDB::Client.new(host: host, retry: retries)
    return db.version
  end
  
end 
