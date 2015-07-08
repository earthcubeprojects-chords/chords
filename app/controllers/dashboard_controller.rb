class DashboardController < ApplicationController
  def index

    # Collect some summary metrics
    @metrics = {}
    @metrics["db_size_mb"]        = ApplicationHelper.total_db_size_mb
    @metrics["measurement_count"] = Measurement.count
    @metrics["site_count"]        = Site.count
    @metrics["instrument_count"]  = Instrument.count
    @metrics["last_url"]          = Instrument.find(Measurement.last.instrument_id).last_url

    # Create data series with the count of samples (measurements) made within regular time
    # intervals. The series are time referenced, and the time is always in ms since the Epoch UTC.
    # It is important to remember that the times always reference UTC. The local time offset 
    # from UTC is provided as a convenience to functions which want to display in local time.
        
    # Get the timezone and compute the offset in minutes from UTC.
    # This is made available to anyone who needs display the time as a local time. 
    timezone = Profile.first.timezone
    tz = ActiveSupport::TimeZone[timezone]
    @tz_offset_mins = -tz.utc_offset() / 60
    @tz_name = timezone
    if Time#dst?
      @tz_name += ' DST'
      @tz_offset_mins -= 60;
    end
    
    # Create a table of number of measurements by minute
    @start_time_by_minute    = Time.now - 2.hour
    print  '@start_time_by_minute ', @start_time_by_minute, "\n"
    @samples_by_minute =  measurement_counts_by_interval(:minute, @start_time_by_minute, by_inst=true)
    
    # Create a table of number of measurements by hour
    @start_time_by_hour      = Time.now - 7.day
    print '@start_time_by_hour ', @start_time_by_hour, "\n"
    @samples_by_hour =  measurement_counts_by_interval(:hour, @start_time_by_hour, by_inst=true)

    # Create a table of number of measurements by day. Not broken out by instrument
    @start_time_by_day       = Time.now - 30.day
    print '@start_time_by_day ', @start_time_by_day, "\n"
    @samples_by_day =  measurement_counts_by_interval(:day, @start_time_by_day, by_inst=false)
    
    @end_time = Time.now

  end

  ################################################################
  def to_ms(time_string)
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
  #     @series_by_minute = measurement_counts_by_interval(:minute, 4.hour)
  # you can import this into the javascript with:
  # series = JSON.parse('<%= @series_by_minute.to_json.html_safe %>')
 
  #  
  def measurement_counts_by_interval(time_resolution, start_time, by_inst)
  
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
    
    print 'Search for times > ', start_time, "\n"
    
    measurements_by_interval = []
    j = 0
    instrument_ids.each do |i|
      measurements_by_interval[j] = Measurement
        .where("created_at >= ? and instrument_id = ?", start_time, i)
        .group("date_format(created_at, '#{time_format}')")
        .count
      j += 1
    end
    
    # Create an array of uniq time keys
    time_keys = []
    measurements_by_interval.each do |m|
      time_keys += m.keys
    end
    time_keys = time_keys.uniq.sort
    
    # Create a hash of count arrays, using a integer index as the key. (makes
    # it look like a two dimensional array). Each row has an array containing
    # accumulating counts for the instruments.
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
    times_ms = time_keys.map {|t| to_ms(t.to_s + iso_suffix)}
    
    # Create structured data for the Highcharts series attribute. The
    # structure will have one series per instrument, if by_inst is true,
    # or only one series if by_inst_is false.
    
    series = []
    if by_inst == true
      (0..ninstruments-1).each do |col|
        trace = {}
        trace[:name] = instrument_names[col]
        trace[:lineWidth] = 2
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
      trace[:lineWidth] = 2
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
