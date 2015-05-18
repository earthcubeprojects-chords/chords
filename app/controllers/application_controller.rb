class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_before_profile
  
  def set_before_profile
    @before_profile = Profile.first

    if @before_profile == nil
      Profile.initialize
      @before_profile = Profile.first
    end



    start_time = Time.zone.now - 10.hour
    @measurements_by_minute = Measurement.where("created_at >= ?", start_time).group("date_format(created_at, '%Y-%m-%dT%H:%i')").count

    data_array = Array.new
    @measurements_by_minute.each do |measurement_by_minute| 
      iso8601 =      measurement_by_minute[0] + ':00+07:00'
      miliseconds = (Time.iso8601(iso8601).to_f * 1000.0).to_i
      str = '[' + miliseconds.to_s + ','+ measurement_by_minute[1].to_s + ']'
      data_array.push(str)
    end
    
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
