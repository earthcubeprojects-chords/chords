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


    pid = Process.pid
    output_file_name = "pid_#{pid}_instrument_#{var.instrument_id}_var_#{var.id}.csv"
    
    # output_file_name = "tmp.csv"
    output_file_path = "/tmp/#{output_file_name}"

    # Export the influxdb data to a temp file
    command = "curl -XPOST '#{url}' --data-urlencode \"#{query}\"   > #{output_file_path} "
    system(command)

    self.json_to_csv(output_file_path)

    site_row = self.csv_row(var.instrument.site, self.site_fields)
    instrument_row = self.csv_row(var.instrument, self.instrument_fields)
    var_row = self.csv_row(var, self.var_fields)

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


  def self.site_fields
    site_fields = [
      'id',
      'name',
      'lat',
      'lon',
      'elevation',
      'site_type.name',
    ]

    # Sites
    # t.string "name"
    # t.decimal "lat", precision: 12, scale: 9
    # t.decimal "lon", precision: 12, scale: 9
    # t.decimal "elevation", precision: 12, scale: 6, default: "0.0"
    # t.integer "site_type_id"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    # t.text "description"

    # Site Types
    # t.string "name"
    #   t.text "definition"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false


    return site_fields
  end


  def self.instrument_fields
    instrument_fields = [
      'id',
      'name',
      'sensor_id',
      'display_points',
      'sample_rate_seconds',

      'topic_category.name',
    ]

    # Instruments
    # t.string "name"
    # t.string "sensor_id"
    # t.integer "display_points", default: 120
    # t.integer "sample_rate_seconds", default: 60
    #   t.integer "site_id"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.text "last_url"
    #   t.text "description"
    #   t.integer "plot_offset_value", default: 1
    #   t.string "plot_offset_units", default: "weeks"
    #   t.integer "topic_category_id"
    #   t.boolean "is_active", default: true
    #   t.bigint "measurement_count", default: 0, null: false
    #   t.bigint "measurement_test_count", default: 0, null: false

    # Topic Category
    # t.string "name"
    #   t.text "definition"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false

    return instrument_fields
  end




  def self.var_fields
    var_fields = [
      'name',
      'shortname',
      'general_category',
      'minimum_plot_value',
      'maximum_plot_value',

      'measured_property.name',
      'measured_property.label',
      # 'measured_property.url',
      # 'measured_property.source',

      'unit.name',
      'unit.abbreviation',
      'unit.id_num',
      'unit.unit_type',
      # 'unit.source',
    ]

    # Vars
    # t.string "name"
    # t.integer "instrument_id"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "shortname"
    # t.integer "measured_property_id", default: 795, null: false
    # t.float "minimum_plot_value"
    # t.float "maximum_plot_value"
    # t.integer "unit_id", default: 1
    # t.string "general_category", default: "Unknown"

    # Measured Properties
    # t.string "name"
    # t.string "label"
    # t.string "url"
    # t.text "definition"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "source", default: "SensorML"

    # Units
    # t.string "name"
    # t.string "abbreviation"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.integer "id_num"
    # t.string "unit_type"
    # t.string "source"

    return var_fields
  end


  def self.row_labels
    row_labels = Array.new

    prefix = 'site'
    fields = self.site_fields
    fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'instrument'
    fields = self.instrument_fields
    fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'var'
    fields = self.var_fields
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