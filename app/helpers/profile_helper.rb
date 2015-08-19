module ProfileHelper

  def self.tz_name_and_tz_offset
  
    # Get the timezone and compute the offset in minutes from UTC.
    # This is made available to anyone who needs display the time as a local time. 
    timezone = Profile.last.timezone
    tz = ActiveSupport::TimeZone[timezone]
    tz_offset_mins = -tz.utc_offset() / 60
    tz_name = timezone
    if tz.parse(Time.now.to_s).dst?
      tz_name += ' DST'
      tz_offset_mins -= 60;
    end
    
    return tz_name, tz_offset_mins
    
  end
    
end
