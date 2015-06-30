class DashboardController < ApplicationController
  def index

    # Summary metrics
    @metrics = {}
    @metrics["db_size_mb"]        = ApplicationHelper.total_db_size_mb
    @metrics["measurement_count"] = Measurement.count
    @metrics["site_count"]        = Site.count
    @metrics["instrument_count"]  = Instrument.count
    @metrics["last_url"]          = Instrument.find(Measurement.last.instrument_id).last_url

    # Get all of our instrument ids.
    instrument_ids = Instrument.pluck(:id)
    
    # Create a table of number of measurements for each minute 
    start_time = Time.zone.now - 2.hour
    
    data_arrays = []
    j = 0
    instrument_ids.each do |i|
      measurements_by_minute = Measurement
        .where("created_at >= ? and instrument_id = ?", start_time, i)
        .group("date_format(created_at, '%Y-%m-%dT%H:%i')")
        .count

      data_arrays[j] = Array.new
      measurements_by_minute.each do |measurement_by_minute| 
        iso8601 =      measurement_by_minute[0] + ':00+07:00'
        milliseconds = (Time.iso8601(iso8601).to_f * 1000.0).to_i
        str = '[' + milliseconds.to_s + ','+ measurement_by_minute[1].to_s + ']'
        data_arrays[j].push(str)
      end
      j += 1
    end
    @measurements_by_minute_data = data_arrays[0].join(',')
    
    # Create a table of number of measurements by hour
    start_time = Time.zone.now - 10.day
    @measurements_by_hour = Measurement.where("created_at >= ?", start_time).group("date_format(created_at, '%Y-%m-%dT%H')").count

    data_array = Array.new
    @measurements_by_hour.each do |measurement_by_hour| 
      iso8601 =      measurement_by_hour[0] + ':00:00+07:00'
      miliseconds = (Time.iso8601(iso8601).to_f * 1000.0).to_i
      str = '[' + miliseconds.to_s + ','+ measurement_by_hour[1].to_s + ']'
      data_array.push(str)
    end
    
    @measurements_by_hour_data = data_array.join(',')

  end
end
