class SaveTsPoints
  
  def self.call(measurements)

      influxdb = InfluxDB::Client.new INFLUXDB_CONFIG['database'],
        host: INFLUXDB_CONFIG['host'],
        port: INFLUXDB_CONFIG['port'],
        username: INFLUXDB_CONFIG['username'],
        password: INFLUXDB_CONFIG['password']
      
      
      precision = 'ms'

      # data = {
      #   values:    { value: value },
      #   tags:      tags,
      #   timestamp: timestamp
      # }
            
      series_name= 'tsdata'
      # influxdb.write_points(name, data, precision)      


      # data = [
      #   {
      #     series: 'cpu',
      #     tags: { host: 'server_1', regios: 'us' },
      #     values: {internal: 5, external: 0.453345}
      #   },
      #   {
      #     series: 'gpu',
      #     values: {value: 0.9999},
      #   }
      # ]

      data = self.create_data_array(series_name, measurements)

      Rails.logger.debug "data: #{data}"

      influxdb.write_points(data, precision)      
  end


  def self.create_data_array(series_name, measurements)
    data = Array.new

    measurements.each do |measurement|
      m = 
        {
          series: series_name,
          values: {value: measurement.value},
          tags: measurement.tags,
          timestamp: measurement.timestamp
        }

      data.push(m)
    end

    return(data)
  end

end