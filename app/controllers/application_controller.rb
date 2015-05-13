class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_before_profile
  
  def set_before_profile
    @before_profile = Profile.find(1)

    @measurements_by_minute = Measurement.group("date_format(created_at, '%Y/%m/%d %H:%i')").count
    @measurements_by_hour = Measurement.group("date_format(created_at, '%Y/%m/%d %H')").count

  end
  
end
