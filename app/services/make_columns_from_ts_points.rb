class MakeColumnsFromTsPoints
  # points        - An array of points. Note that the instrument id is ignored,
  # so points should be pre-selected for the desired instrument. The points are ordered by
  # time, and then var id.
  # Each point contains a hash matching the CHORDS TsPoint schema:
  #   {"time": timestamp,   "inst": instrument_id, 
  #    "site": site_id,     "test": true_or_false, "
  #    "var":  variable_id, "#{field}": point_value}
  #
  # field          - The field to use as the data source
  #
  # varnames_by_id - A hash of var names, indexed by the var id.:
  #  {
  #    1: "Pressure",
  #    ...
  #    N: "Temperature
  #  }
  #
  # Returns a hash containing vectors. One vector contains the timestamps, 
  # the other vectors contain var values for those timestamps:
  # {
  #   "time":  [ordered time stamps]
  #   1:       [values for instrument id 1 (nil when missing)]
  #   ...
  #   N:       [values for instrument id N (nil when missing)]
  # }
  def self.call(points, field, varnames_by_id)
    
    # Get the variable keys
    var_ids = varnames_by_id.keys
    
    # vardata will be a hash of arrays, each array corresponding to a column
    vardata = {}

    # Create the time array.
    vardata["time"] = points.map { |p| p["time"] }.uniq.sort
      
    # Create array indices hashed from the times
    time_indices = {}
    vardata["time"].each_index {|i| time_indices[vardata["time"][i]] = i}
      
    # Create the var arrays
    var_ids.each {|var_id| vardata[var_id] = Array.new(vardata["time"].length, nil)}
    
    # Collect the var data values for each point.
    if points.length > 0
      point_time = points[0]["time"]
      index = time_indices[point_time]
      points.each do |point| 
        if point_time != point["time"]
          point_time = point["time"]
          index = time_indices[point_time]
        end
        vardata[point["var"].to_i][index] = point[field]
      end
    end

#    (0..vardata["time"].length-1).each do |i|
#      line = vardata["time"][i]
#      var_ids.each do |var_id|
#        line = line + " " + vardata[var_id][i].to_s
#      end 
#    end
#    Rails.logger.debug line

    return vardata
    
  end
end
