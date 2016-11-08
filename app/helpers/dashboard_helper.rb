module DashboardHelper

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
  def self.highcharts_series(time_resolution, end_time)
 
    # Get all of our instrument ids and names.
    instrument_ids = []
    instrument_names = {}
    Instrument.all.each do |i|
      instrument_ids << i.id
      instrument_names[i.id] = i.name
    end
    
    # Get the timeseries counts for the data field
    minute_s = 60
    hour_s   = minute_s*60
    day_s    = 24*hour_s
    field = "value"
    case time_resolution
      when :minute
        counts = GetTsCountsByInterval.call(TsPoint, end_time, 2*hour_s,  "1m", field, instrument_ids)
      when :hour
        counts = GetTsCountsByInterval.call(TsPoint, end_time,  7*day_s,  "1h", field, instrument_ids)
      else
        counts = GetTsCountsByInterval.call(TsPoint, end_time, 60*day_s,  "1d", field, instrument_ids)
    end
    
    # The return data will be an array of hashes, each one corresponding
    # to an instrument. Reconfigure these to be used as the highcharts series
    # attribute.
    series = []
    counts.each do |id, data|
      series << { name: instrument_names[id], data: data }
    end
    
    return series
  end

end
