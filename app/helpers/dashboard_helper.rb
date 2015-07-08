module DashboardHelper

  ################################################################
  def self.to_ms(time_string)
      ms = ((Time.iso8601(time_string).to_f) * 1000.0).to_i
      return ms
  end
  
  ################################################################
  # Summarize the number of measurements per time unit,
  # for each instrument. The time unit and the time span
  # are parameters.
  #
  # If by_inst is false,  the samples will not be broken ot by instrument.
  #
  # A structured object is returned that is suitable for using as the 
  # series atribute in a highchart chart. It will be an array of hashes. 
  # Each hash contains attributes for one trace, including the data for 
  # that trace.
  #
  # The returned object can be turned into json, using .to_json.
  # This can then be translated to javascript using the javascript
  # function JSON.parse(). 
  #
  # E.g., if you called make_highchart_series as:
  #     @series_by_minute = highcharts_series(:minute, 4.hour)
  # you can import this into the javascript with:
  # series = JSON.parse('<%= @series_by_minute.to_json.html_safe %>')
 
  #  
  def self.highcharts_series(time_resolution, start_time, by_inst)
  
    # Set the time format to be used in SQL group query
    # 
    time_format = "%Y-%m-%dT%H:%i"
    iso_suffix  = ":00"
    case time_resolution
    when :minute
      time_format = "%Y-%m-%dT%H:%i"
      iso_suffix  = ":00+00:00"
    when :hour
      time_format = "%Y-%m-%dT%H"
      iso_suffix  = ":00:00+00:00"
    when :day
      time_format = "%Y-%m-%d"
      iso_suffix  = "T00:00:00+00:00"
    else
    end

    # Get all of our instrument id and names.
    instrument_ids   = Instrument.pluck(:id)
    instrument_names = Instrument.pluck(:name)
    ninstruments     = Instrument.count
    
    # Get the count of measurements for each instrument, for each interval.
    # The database queries returns a hash, with the keys being the date, 
    # and the values being the counts. The vector measurements_by_interval[]
    # is created, where each entry represents the database hash for one instrument.
    # The date keys will have the same format as the original query, e.g.
    # "2015-07-08T14:34" or "2015-07-01T17" or "2015-07-03".
    measurements_by_interval = []
    j = 0
    instrument_ids.each do |i|
      measurements_by_interval[j] = Measurement
        .where("created_at >= ? and instrument_id = ?", start_time, i)
        .group("date_format(created_at, '#{time_format}')")
        .count
      j += 1
    end
    
    # Create a vector of unique time keys. This is accomplished
    # by collecting all of the time keys for all instruments,
    # and then making that list uniqued (and sorted).
    time_keys = []
    measurements_by_interval.each do |m|
      time_keys += m.keys
    end
    time_keys = time_keys.uniq.sort
    
    # time_keys now has all of the times for which at least one instrument has 
    # at least one measurement.Note that there will be gaps, where no measurements
    # were found, and thus no key exists.
    
    # Create a hash of count arrays, using an integer index as the key. (makes
    # it look like a two dimensional array). Each entry has an array containing
    # accumulating counts for the instruments. If there are no counts for a particular
    # instrument, the value is set to zero.
    counts_by_time_by_inst = {}
    t = 0
    time_keys.each do |k|
      counts_by_time_by_inst[t] = Array.new
      j = 0
      measurements_by_interval.each do |m|
        if m[k] != nil
          counts_by_time_by_inst[t][j] = m[k]
        else
          counts_by_time_by_inst[t][j] = 0
        end
        j += 1
      end
      t += 1
    end
    
    ntimes = counts_by_time_by_inst.count

    # Create an array of millisecond times from the unique time keys
    # The proper iso suffixe has to be added, since the times
    # returned from the database query doesn't have this.
    times_ms = time_keys.map {|t| to_ms(t.to_s + iso_suffix)}
    
    # Create structured data for the Highcharts series attribute. The
    # structure will have one series per instrument, if by_inst is true,
    # or only one series if by_inst_is false.
    
    series = []
    if by_inst == true
      (0..ninstruments-1).each do |col|
        trace = {}
        trace[:name] = instrument_names[col]
        trace[:lineWidth] = 0
        trace[:marker] = {radius: 3}
        trace[:data] = []
	    (0..ntimes-1).each do |row|
	      point = []
	      point.append(times_ms[row])
	      point.append(counts_by_time_by_inst[row][col])
	      trace[:data].append(point)
        end
        series.append(trace)
      end
    else
      trace = {}
      trace[:name] = "All Instruments"
      trace[:lineWidth] = 0
      trace[:marker] = {radius: 3}
      trace[:data] = []
	  (0..ntimes-1).each do |row|
	    point = []
	    point.append(times_ms[row])
	    sum = 0
        (0..ninstruments-1).each do |col|
          sum += counts_by_time_by_inst[row][col]
        end
	    point.append(sum)
	    trace[:data].append(point)
      end
      series.append(trace)
    end
    
    return series
  end

end
