require 'influxdb'

class TSDB

  def initialize(dbname, host)
    @db = InfluxDB::Client.new dbname, host: host
  end
  
  def query(q)
    return @db.query(q)
  end
  
  def write(site, name, time, value)
    q_result = @db.query
    return q_result
  end
end 
