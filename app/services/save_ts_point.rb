class SaveTsPoint
  
  def self.call(timestamp, value, tags)

      influxdb = InfluxDB::Client.new INFLUXDB_CONFIG['database'],
        host: INFLUXDB_CONFIG['host'],
        port: INFLUXDB_CONFIG['port'],
        username: INFLUXDB_CONFIG['username'],
        password: INFLUXDB_CONFIG['password']
      
      
      data = {
        values:    { value: value },
        tags:      tags,
        timestamp: timestamp
      }
            
      name= 'tsdata'
      precision = 'ms'
      influxdb.write_point(name, data, precision)      
  end
end