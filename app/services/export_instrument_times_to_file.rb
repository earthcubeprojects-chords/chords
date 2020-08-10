class ExportInstrumentTimesToFile
  # def self.call(var_id, start_time, end_time, include_test_data, site_fields, instrument_fields, var_fields, output_file_path)

  def self.call(instrument, bd)


    output_file_path =  bd.instrument_times_temp_output_file_path(instrument)


    influxdb_database_name = "chords_ts_#{ENV['RAILS_ENV']}"
    series = 'tsdata'
    chunk_size = true  # tell influx db to stream the data in chunks so we can bypass the max-row-limit setting

    url = "http://influxdb:8086/query?db=#{influxdb_database_name}&p=#{ENV['INFLUXDB_PASSWORD']}&u=#{ENV['INFLUXDB_USERNAME']}&chunked=#{chunk_size}"

    # Build the influxdb query
    query = "q=select time, value from #{series} WHERE "

    query += " time >= '#{bd.start_time.strftime('%Y-%m-%d')} 00:00:00' AND time <= '#{bd.end_time.strftime('%Y-%m-%d')} 00:00:00'"

    counter = 1
    instrument.vars.each do |var|
      if (counter == 1)
        query += " AND"
      else
        query += " OR"
      end
      query += " var=\'#{var.id}\'"
      counter += 1
    end


    unless bd.include_test_data.to_s == 'true'
      query += " AND test=\'false\'"
    end

    # # false limit on number of results(for testing)
    # query += " LIMIT 10"
    

    # Export the influxdb data to a temp csv file
    command = "curl -XPOST '#{url}' --data-urlencode \"#{query}\"   > #{output_file_path} "
    system(command)



    self.json_to_csv(output_file_path)


    # remove everything but the times
    times_only_file_path = "#{BulkDownload.processing_dir}/#{bd.random_job_id}_times_only_instrument_#{instrument.id}.csv"
    command = "sed -e 's/,.*$//g' < #{output_file_path} > #{times_only_file_path}"
    system(command)


    # get unique entries and make sure it is sorted
    command = "uniq #{times_only_file_path}  | sort > #{output_file_path}"
    system(command)


    File.delete(times_only_file_path)

    return output_file_path

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