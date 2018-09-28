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

  def self.replace_model_instances_from_JSON (model, json_array)
    if json_array.kind_of?(Array)

      json_array.each do |json_object|
        new_object = model.new
        new_object.assign_attributes(json_object)

        new_object.save(validate: false)
      end

    else
      return false
    end
  end

    # Return DOI citation
  def get_citation(doi)
    begin
      %x(curl -LH "Accept: text/x-bibliography; style=apa" https://doi.org/#{doi})
    rescue Exception, e
      "DOI citation could not be found"
    end
  end

end
