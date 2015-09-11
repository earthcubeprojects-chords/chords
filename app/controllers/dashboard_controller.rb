class DashboardController < ApplicationController
  
  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}
    
  def index

    # Get all of the instruments.
    @instruments = Instrument.all

    if @profile.secure_data_viewing
      authorize! :view, @instruments[0]
    end


    # Collect some summary metrics
    @metrics = {}
    @metrics["db_size_mb"]        = ApplicationHelper.total_db_size_mb
    @metrics["measurement_count"] = Measurement.count
    @metrics["site_count"]        = Site.count
    @metrics["instrument_count"]  = Instrument.count
    @metrics["uptime"]            = ApplicationHelper.uptime
    if Measurement.last
      @metrics["last_url"]          = Instrument.find(Measurement.last.instrument_id).last_url
    else
      @metrics["last_url"]          = ''
    end

    # Create data series with the count of samples (measurements) made within regular time
    # intervals. The data series are structured like the elements that provide
    # data for the highcharts' series: field. For that reason, the series will have plotting
    # attributes embedded, such as lineWidth:, marker:, etc.
    #
    # Use JSON.parse('<%= @samples_by_minute.to_json.html_safe %>')
    # to convert to javascript.
    #
    # The series are time referenced, and the time is in ms since the Epoch UTC.
    # It is important to remember that the times always reference UTC. The local time offset 
    # from UTC is provided as a convenience to functions which want to display in local time.
        
    # Get the timezone name and offset in minutes from UTC.
    @tz_name, @tz_offset_mins = ProfileHelper::tz_name_and_tz_offset
    
    # Create a table of number of measurements by minute
    @start_time_by_minute = Time.now - 2.hour
    @samples_by_minute    =  DashboardHelper.highcharts_series(:minute, @start_time_by_minute, by_inst=true)
    
    # Create a table of number of measurements by hour
    @start_time_by_hour = Time.now - 7.day
    @samples_by_hour    =  DashboardHelper.highcharts_series(:hour, @start_time_by_hour, by_inst=true)

    # Create a table of number of measurements by day.
    @start_time_by_day = Time.now - 60.day
    @samples_by_day    =  DashboardHelper.highcharts_series(:day, @start_time_by_day, by_inst=true)
    
    @end_time = Time.now

  end
  
end
