class MakeColumnsFromTsPoints
  # points - An array of points. Note that the instrument id is ignored,
  # so points should be pre-selected for the desired instrument.
  # Each point contains a hash matching the CHORDS TsPoint schema:
  #   {"time": timestamp,   "inst": instrument_id, 
  #    "site": site_id,     "test": true_or_false, "
  #    "var":  variable_id, "#{field}": point_value}
  # field  - The field to use as the data source
  # vars   - an array of variable ids that should be extracted from points.
  #
  # Returns a hash containing vectors. One vector contains the timestamps, 
  # the other vectors contain var values for those timestamps:
  # {
  #   "time":  [ordered time stamps]
  #   1:       [values for instrument id 1 (nil when missing)]
  #   ...
  #   N:       [values for instrument id N (nil when missing)]
  # }
  def self.call(points, field, vars)
    
    # vardata will be a hash of arrays, each array corresponding to a column
    vardata = {}

    # Create the time array.
    vardata["time"] = points.map { |p| p["time"] }.uniq.sort
      
    # Create the var arrays
    vars.each do |var|
      vardata[var] = Array.new(vardata["time"].length, nil)
    end
    
    # Collect the var data values for each point.
    points.each do |point| 
      point_time = point["time"]
      # find the array index for this time
      index = vardata["time"].find_index(point_time)
      vars.each do |var|
        if point["var"].to_i == var
          vardata[var][index] = point[field]
          break
        end
      end
    end

    (0..vardata["time"].length-1).each do |i|
      line = vardata["time"][i]
      vars.each do |var|
        line = line + " " + vardata[var][i].to_s
      end 
    end

    return vardata
    
  end
end
