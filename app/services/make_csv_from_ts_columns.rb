class MakeCsvFromTsColumns
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
  def self.call(ts_points, metadata, varnames_by_id)
    
    # Create column arrays of data points
    ts_columns = MakeColumnsFromTsPoints.call(ts_points, "value", varnames_by_id)

    # Get the number of items in each array
    n = ts_columns["time"].length
    
    # Collect the CSV column titles from varnames
    column_titles = []
    column_titles << "Time"
    varnames_by_id.each { |k, v| column_titles << v}
    
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
        end
        csv << row
      end
      
    end
    
    return csv
  end
end