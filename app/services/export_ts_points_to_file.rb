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
  def self.call(time_series_db, var_id)

    var = Var.find(var_id)

    influxdb_database_name = "chords_ts_#{ENV['RAILS_ENV']}"
    series = 'tsdata'
    chunk_size = true  # tell influx db to stream the data in chunks so we can bypass the max-row-limit setting


    url = "http://influxdb:8086/query?db=#{influxdb_database_name}&p=#{ENV['INFLUXDB_PASSWORD']}&u=#{ENV['INFLUXDB_USERNAME']}&chunked=#{chunk_size}"
    query = "q=select value from #{series} WHERE var=\'#{var.id}\' "

    query = "q=select value from #{series} WHERE var=\'#{var.id}\' LIMIT 10 "


    pid = Process.pid
    output_file_name = "pid_#{pid}_instrument_#{var.instrument_id}_var_#{var.id}.csv"

    # output_file_name = "tmp.csv"
    output_file_path = "/tmp/#{output_file_name}"

    # Export the influxdb data to a temp file
    command = "curl -XPOST '#{url}' --data-urlencode \"#{query}\"   > #{output_file_path} "
    system(command)

    self.json_to_csv(output_file_path)

    site_row = self.csv_row(var.instrument.site, BulkDownload.site_fields)
    instrument_row = self.csv_row(var.instrument, BulkDownload.instrument_fields)
    var_row = self.csv_row(var, BulkDownload.var_fields)

    row_suffix = "#{site_row},#{instrument_row},#{var_row}"
    # puts row_suffix

    row_labels = self.row_labels
    # puts row_labels

    # puts site_row
    # puts var_row
    # puts instrument_row

    # var_row_labels.to_csv

    script = "s*$*#{row_suffix}*"
    system "sed", "-i", "-e", script, output_file_path



    command = "gzip -f #{output_file_path}"
    system(command)


    zip_file_name = "#{output_file_path}.gz"

    # file = File.open(output_file_path)
    # puts file.read

    return zip_file_name
  end


  def self.row_labels
    row_labels = Array.new

    prefix = 'site'
    fields = BulkDownload.site_fields
    fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'instrument'
    fields = BulkDownload.instrument_fields
    fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'var'
    fields = BulkDownload.var_fields
    fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end


    return row_labels.join(',')
  end


  def self.csv_row(object, object_fields)
    values = Array.new

    object_fields.each do |object_field|
      begin
        value = [eval("object.#{object_field}")]
      rescue
        # rescus in case one of the shild properties is undefined
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