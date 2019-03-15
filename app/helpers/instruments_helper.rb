module InstrumentsHelper
  def self.sanitize_url(url)
    # Sanitize a url by obscuring the security key in the url.
    return '' unless url

    # Look for the key terminated by "&"
    re = /key=.+&/

    new_url = if re.match(url)
                url.gsub(re, 'key=hidden&')
              else
                # Look for key at the end of the url
                re = /key=.+/

                if re.match(url)
                  url.gsub(re, 'key=hidden')
                else
                  ''
                end
              end

    return new_url.html_safe
  end

  def put_data_url
    url = url_for(only_path: false, host: request.host, controller: 'measurements', action: 'url_create', instrument_id: @instrument.id)

    @instrument.vars.each do |var|
      url +=  "&#{var.shortname}=#{var.name}"
    end

    url += "&at=2015-08-20T19:50:28"
    url += "&email=[USER_EMAIL]&api_key=[API_KEY]"
    url += "&test"
    return url
  end

  def put_data_url_with_sensor_id
    url = "#{root_url}measurements/url_create?sensor_id=#{@instrument.sensor_id}"

    @instrument.vars.each do |var|
      url +=  "&#{var.shortname}=#{var.name}"
    end

    url += "&at=2015-08-20T19:50:28"
    url += "&email=[USER_EMAIL]&api_key=[API_KEY]"
    url += "&test"
    return url
  end

  def data_file_download_url(file_extension, range = nil)
    url = url_for(only_path: false, host: request.host, controller: 'api/v1/data', action: :show, id: @instrument.id)
    url += ".#{file_extension}"

    if range
      url += "?"
    end

    if range == 'last'
      url += "last"
    elsif range == 'start_end'
      url += "start=2015-08-01T00:30&end=2015-08-20T12:30"
    end

    return url
  end

  def multi_inst_data_file_download_url(file_extension, range = nil, ids = nil, test_data = false, auth = false)
    url = url_for(only_path: false, host: request.host, controller: 'api/v1/data', action: :index)
    url += ".#{file_extension}" if file_extension

    if range || ids || test_data || auth
      url += "?"
    end

    case ids
    when 'sensors'
      url += 'sensors=sen1,sen2,sen3'
    when 'instruments'
      url += 'instruments=1,2,3'
    end

    if ids && range
      url += '&'
    end

    case range
    when 'start_end'
      url += "start=2015-08-01T00:30&end=2015-08-20T12:30"
    end

    if test_data
      url += '&' if (range || ids)
      url += 'test'
    end

    if auth
      url += '&' if (range || ids || test_data)
      url += "email=[USER_EMAIL]&api_key=[API_KEY]"
    end

    return url
  end

  # =>  return js for use in simulator
  def create_instrument_variables_js(instruments)
    js_lines = Array.new

    instruments.each do |instrument|
      js_lines.push("var instrument_#{instrument.id}_run_status = false;")
      js_lines.push("var instrument_#{instrument.id}_shortnames = [];")

      instrument.vars.each do |var|
        js_lines.push("instrument_#{instrument.id}_shortnames.push(\"#{var.shortname}\");")
      end
    end


    return js_lines.join("\n")
  end

  def get_security_key_url_fragment
    url_fragment = ''

    # add the security key
    if @profile.secure_data_entry == true
      begin
        url_fragment = "&email=" + current_user.email + "&api_key=" + current_user.api_key
      rescue TypeError
        url_fragment = "&email=" + current_user.email + "&api_key=[INSERT_API_KEY]"
      end
    end

    return url_fragment.html_safe
  end

end
