require 'influxdb'
require 'json'

class TSDB

  def initialize(dbname, host, precision='ms')
    
    exists = false
    databases = self.list_databases(host)
    databases.each do |d|
      if d["name"] == dbname then
        exists = true
      end
    end
    
    if !exists then
      self.create_database(dbname, host)
      print "Database #{dbname} created on host #{host}\n"
    end
    
    @db = InfluxDB::Client.new dbname, host: host, time_precision: precision
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

  def list_databases(host)
    db = InfluxDB::Client.new(host: host)
    return db.list_databases
  end

  def create_database(dbname, host)
    db = InfluxDB::Client.new(host: host)
    db = db.create_database(dbname)
  end
end 
