class MakeGeoCsvFromTsPoints
  # Create a CSV object from columnized data
  #
  # ts_columns     - a hash containing arrays of ts data. 
  #  There must be an array identified as "time"
  #  All other arrays are hashed by the variable id.
  #  {
  #    "time":  [ordered time stamps]
  #    1:       [values for instrument id 1 (nil when missing)]
  #    ...
  #    N:       [values for instrument id N (nil when missing)]
  #  }
  # metadata       - An array of metadata to be prepended to the CSV output
  # varnames_by_id - A hash of var names, indexed by the var id.:
  #  {
  #    1: "Pressure",
  #    ...
  #    N: "Temperature
  #  }
  def self.call(ts_points, metadata, varnames_by_id, instrument, host)

    # geocsv header
    units_of_measure = instrument.vars.map { |v| v.units }.join(', ')
    field_types = instrument.vars.map { |v| 'float' }.join(', ')

    header_lines = Array.new
    header_lines.push("# dataset: GeoCSV 2.0")
    header_lines.push("# field_unit: ISO_8601 #{units_of_measure}")
    header_lines.push("# field_type: datetime, #{field_types}")
    header_lines.push("# attribution: #{host}")
    header_lines.push("# delimiter: ,")
    header_lines.push("# device_information: #{instrument.name}")
    header_lines.push("# creation_date: #{Time.now.to_s}")
    header_lines.push("# data collection site: #{instrument.site.name}")
    header_lines.push("# data collection longitude: #{instrument.site.lon}")
    header_lines.push("# data collection latitude: #{instrument.site.lat}")
    header_lines.push("# data collection elevation: #{instrument.site.elevation} meters")
    header_lines.push("# Units of Measure: (milliseconds, #{units_of_measure})")
    

    
    # Create column arrays of data points
    ts_columns = MakeColumnsFromTsPoints.call(ts_points, "value", varnames_by_id)

    # Get the number of items in each array
    n = ts_columns["time"].length
    
    # Collect the CSV column titles from varnames
    column_titles = []
    column_titles << "Time"
    varnames_by_id.each { |k, v| column_titles << v}
    
    # measurement count
    measurement_count = 0
    
    # Generate CSV
    csv = CSV.generate do |csv|
      
      # Put the metadata at the head of the CSV, one line per group
      metadata.each do |line|
        csv << line
      end
      
      # Add column titles
      csv << column_titles
      
      # add values for each timestamp
      (0..n-1).each do |i|
        # One row per timestamp
        row = []
        row << ts_columns["time"][i]

        varnames_by_id.keys.each do |k, v|
          # Nil values will create ',,'
          row << ts_columns[k][i]
          
          if ts_columns[k][i] != nil
            measurement_count += 1
          end
          
        end
        csv << row
      end
      
    end

    header_lines.push("# Measurements in File: #{measurement_count}")
    
    header = header_lines.join("\n")
    
    return header + "\n" + csv
  end
end