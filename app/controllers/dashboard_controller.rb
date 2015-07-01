class DashboardController < ApplicationController
  def index

    # Summary metrics
    @metrics = {}
    @metrics["db_size_mb"]        = ApplicationHelper.total_db_size_mb
    @metrics["measurement_count"] = Measurement.count
    @metrics["site_count"]        = Site.count
    @metrics["instrument_count"]  = Instrument.count
    @metrics["last_url"]          = Instrument.find(Measurement.last.instrument_id).last_url

    # Create a table of number of measurements for each minute 
    start_time = Time.zone.now - 2.hour
    
    # Get all of our instrument id and names.
    instrument_ids   = Instrument.pluck(:id)
    instrument_names = Instrument.pluck(:name)
    ninstruments     = Instrument.count
    
    # Create a table of number of measurements for each minute 
    start_time = Time.zone.now - 2.hour
    
    measurements_by_minute = []
    j = 0
    instrument_ids.each do |i|
      measurements_by_minute[j] = Measurement
        .where("created_at >= ? and instrument_id = ?", start_time, i)
        .group("date_format(created_at, '%Y-%m-%dT%H:%i')")
        .count
      j += 1
    end
    
    # Create an array of uniq time keys
    time_keys = []
    measurements_by_minute.each do |m|
      time_keys += m.keys
    end
    time_keys = time_keys.uniq.sort
    
    # Create an array of millisecond time strings from the unique time keys
    time_strings = time_keys.map {|t| to_ms_s(t.to_s + ':00+06:00')}
    
    # Create a hash of count arrays, using a integer index as the key. (makes
    # it look like a two dimensional array). Each row has an array containing
    # accumulating counts for the instruments.
    counts_by_time_by_inst = {}
    t = 0
    time_keys.each do |k|
      counts_by_time_by_inst[t] = Array.new
      j = 0
      measurements_by_minute.each do |m|
        if m[k] != nil
          counts_by_time_by_inst[t][j] = m[k]
        else
          counts_by_time_by_inst[t][j] = 0
        end
        if j > 0
          counts_by_time_by_inst[t][j] += counts_by_time_by_inst[t][j-1]
        end
        j += 1
      end
      t += 1
    end

    # Create the javascript for the highcharts "series" parameter
    ntimes = counts_by_time_by_inst.count
    @series_by_min_js = '['
    (0..ninstruments-1).each do |col|
      @series_by_min_js += '{'
      #@series_by_min_js += 'name: \'' + instrument_names[col] + '\', '
      @series_by_min_js += 'lineWidth: 0,'
      @series_by_min_js += 'data: [ '
	  (0..ntimes-1).each do |row|
        @series_by_min_js += '[' 
        @series_by_min_js +=  time_strings[row]
        @series_by_min_js +=  ',' 
        @series_by_min_js += counts_by_time_by_inst[row][col].to_s
		@series_by_min_js += '],'
      end
      @series_by_min_js.chop!
      @series_by_min_js += ']'
      @series_by_min_js += ' },'
    end
    @series_by_min_js.chop!
    @series_by_min_js += ']'

    # Create an array of millisecond times from the unique time keys
    times_ms = time_keys.map {|t| to_ms(t.to_s + ':00+06:00')}
    
    # Create structured data for the Highcharts series attribute,
    # that could be converted directly to json (using .to_json)
    # (But there doesn't seem to be a way to convert from JSON to 
    # Javascript. There must be a way to pull this directly into
    # Highcharts rather than building javascript as above.)
    
    @series = []
    (0..ninstruments-1).each do |col|
      trace = {}
      trace[:name] = instrument_names[col]
      trace[:lineWidth] = 0
      trace[:data] = []
	  (0..ntimes-1).each do |row|
	    point = []
	    point.append(times_ms[row])
	    point.append(counts_by_time_by_inst[row][col])
	    trace[:data].append(point)
      end
      @series.append(trace)
    end
      
    #puts @series.to_json

    # Create a table of number of measurements by hour
    start_time = Time.zone.now - 10.day
    @measurements_by_hour = Measurement.where("created_at >= ?", start_time).group("date_format(created_at, '%Y-%m-%dT%H')").count

    data_array = Array.new
    @measurements_by_hour.each do |measurement_by_hour| 
      iso8601 =      measurement_by_hour[0] + ':00:00+06:00'
      miliseconds = (Time.iso8601(iso8601).to_f * 1000.0).to_i
      str = '[' + miliseconds.to_s + ','+ measurement_by_hour[1].to_s + ']'
      data_array.push(str)
    end
    
    @measurements_by_hour_data = data_array.join(',')

  end

  def to_ms(time_string)
      ms = (Time.iso8601(time_string).to_f * 1000.0).to_i
      return ms
  end
  
  def to_ms_s(time_string)
      return to_ms(time_string).to_s
  end
end
