class ExportTsPointsToFile
  # Return the time series points within the specified time interval. 
  # An array of points will be returned.
  #
  # time_series_db - the database.
  # field          - the field to return.
  # inst_id        - the instrument id.
  # start_time     - beginning time stamp. Times greater or equal will be returned
  # end_time       - the end time. Times less than this will be returned..
  # def self.call(time_series_db, instrument_id, var_id)
  def self.call(var_id, start_time, end_time, include_test_data, site_fields, instrument_fields, var_fields, output_file_path)

    var = Var.find(var_id)

    influxdb_database_name = "chords_ts_#{ENV['RAILS_ENV']}"
    series = 'tsdata'
    chunk_size = true  # tell influx db to stream the data in chunks so we can bypass the max-row-limit setting

    url = "http://influxdb:8086/query?db=#{influxdb_database_name}&p=#{ENV['INFLUXDB_PASSWORD']}&u=#{ENV['INFLUXDB_USERNAME']}&chunked=#{chunk_size}"


    # Build the influxdb query
    query = "q=select value, test from #{series} WHERE var=\'#{var.id}\'"

    query += " AND time >= '#{start_time.strftime('%Y-%m-%d')} 00:00:00' AND time <= '#{end_time.strftime('%Y-%m-%d')} 00:00:00'"
    # query += " AND time >= '2020-05-01 00:00:00' "

    unless include_test_data.to_s == 'true'
      query += " AND test=\'false\'"
    end


    # query += " LIMIT 100"


    # start_time_obj = Time.find_zone("UTC").parse(start_time)
    # start_time_obj = Time.parse(start_time)
    # end_time_obj = Time.parse(end_time)

    # Rails.logger.debug "*" * 80
    # Rails.logger.debug "start_time #{start_time}"
    # Rails.logger.debug "start_time.class #{start_time.class}"
    # Rails.logger.debug "end_time #{end_time}"

    # Rails.logger.debug "start_time.strftime('%Y-%m-%d') #{start_time.strftime('%Y-%m-%d')}"
    # Rails.logger.debug "end_time.strftime('%Y-%m-%d') #{end_time.strftime('%Y-%m-%d')}"
    

    # Rails.logger.debug "#{query}"
    # Rails.logger.debug "*" * 80


    

    # Export the influxdb data to a temp csv file
    command = "curl -XPOST '#{url}' --data-urlencode \"#{query}\"   > #{output_file_path} "
    system(command)

    # Convert the file from it's native JSON format to CSV
    self.json_to_csv(output_file_path)

    # Build the string to add to the end of each csv row
    site_row = self.csv_row(var.instrument.site, site_fields)
    instrument_row = self.csv_row(var.instrument, instrument_fields)
    var_row = self.csv_row(var, var_fields)

    row_suffix = ",#{site_row},#{instrument_row},#{var_row}"



    # Add the suffix on to each line in the csv file
    script = "s*$*#{row_suffix}*"
    system "sed", "-i", "-e", script, output_file_path


    # zip the temp file
    command = "gzip -f #{output_file_path}"
    system(command)


    zip_file_name = "#{output_file_path}.gz"

    # file = File.open(output_file_path)
    # puts file.read

    return zip_file_name
  end



  def self.csv_row(object, object_fields)
    values = Array.new

    object_fields.each do |object_field|
      begin
        value = eval("object.#{object_field}")
      rescue
        # rescue in case one of the shild properties is undefined
        # puts "FAILED " * 40
        # puts object
        # puts object_field
        value = ""
      end
      
      array = [value]

      values.push(array.to_csv.to_s.chomp.dump)
    end

    return values.join(',')
  end


  def self.json_to_csv(file_path)
    sed_command = "sed -i 's/\\],\\[/\\\n/g' #{file_path}"
    system(sed_command)

    sed_command = "sed -i 's/^.*\\[\\[//' #{file_path}"
    system(sed_command)

    sed_command = "sed -i 's/\\]\\].*$//' #{file_path}"
    system(sed_command)
  end
end