class DashboardController < ApplicationController
  def index
    authorize! :view, Instrument

    # Get all of the instruments.
    @instruments = Instrument.accessible_by(current_ability)

    # Collect some summary metrics
    counts = TsPoint.select("count(value)")
    big_count = 0

    counts.each do |c|
      big_count = c["count"]
    end

    @metrics = {}
    @metrics["db_size_mb"] = ApplicationHelper.total_db_size_mb
    @metrics["db_expiry_time"] = ApplicationHelper.db_expiry_time
    @metrics["measurement_count"] = big_count
    @metrics["site_count"] = Site.accessible_by(current_ability).count
    @metrics["instrument_count"] = @instruments.length
    @metrics["uptime"] = ApplicationHelper.server_uptime

    @metrics["last_url"] = InstrumentsHelper.sanitize_url(!@profile.secure_administration,
                                                          !(current_user && (can? :manage, Measurement)),
                                                          GetLastUrl.call(TsPoint))

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
    @end_time = Time.now
    @start_time_by_minute = Time.now - 2.hour
    @samples_by_minute = DashboardHelper.highcharts_series(:minute, @end_time)

    # Create a table of number of measurements by hour
    @start_time_by_hour = Time.now - 7.day
    @samples_by_hour = DashboardHelper.highcharts_series(:hour, @end_time)

    # Create a table of number of measurements by day.
    @start_time_by_day = Time.now - 60.day
    @samples_by_day = DashboardHelper.highcharts_series(:day, @end_time)
  end
end
