class DashboardController < ApplicationController
  def index

    start_time = Time.zone.now - 10.hour
    @measurements_by_minute = Measurement.where("created_at >= ?", start_time).group("date_format(created_at, '%Y-%m-%dT%H:%i')").count

    data_array = Array.new
    @measurements_by_minute.each do |measurement_by_minute| 
      iso8601 =      measurement_by_minute[0] + ':00+07:00'
      miliseconds = (Time.iso8601(iso8601).to_f * 1000.0).to_i
      str = '[' + miliseconds.to_s + ','+ measurement_by_minute[1].to_s + ']'
      data_array.push(str)
    end
    
    # 
    @metrics = {}
    @metrics["db_size_mb"]        = ApplicationHelper.total_db_size_mb
    @metrics["measurement_count"] = Measurement.count
    @metrics["site_count"]        = Site.count
    @metrics["instrument_count"]  = Instrument.count
    
    @measurements_by_minute_data = data_array.join(',')
    
    start_time = Time.zone.now - 10.day
    @measurements_by_hour = Measurement.where("created_at >= ?", start_time).group("date_format(created_at, '%Y-%m-%dT%H')").count


    # @measurements_by_hour = Measurement.group("date_format(created_at, '%Y-%m-%dT%H')").count

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
