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

    # false limit on number of results(for testing)
    # query += " LIMIT 10"

    

    # Export the influxdb data to a temp csv file
    command = "curl -XPOST '#{url}' --data-urlencode \"#{query}\"   > #{output_file_path} "
    system(command)


    command = "grep series #{output_file_path} "
    file_contains_data = system(command)


    if file_contains_data
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

      return zip_file_name
    else
      # The file contains no results - delete it!
      File.delete(output_file_path)
      return false
    end
  end



  def self.csv_row(object, object_fields)
    values = Array.new

    object_fields.each do |object_field|
      begin
        value = eval("object.#{object_field}")
      rescue
        # rescue in case one of the shild properties is undefined
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