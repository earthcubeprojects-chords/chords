module InstrumentsHelper
  def self.sanitize_url(always_allow, sanitize, url)
    #
    # Sanitize a url by obscuring the security key in the url.
    # The key is located between &key=...&,
    # or at the end of the string &key=...

    # "always_allow" and "sanitize" offer control
    # over whether to perform the sanitizing. always_allow
    # is meant as a global override, and sanitize would
    # be applicable to things like user roles.
    
    # if "always_allow" is true, do not sanitize
    # otherwise
    #  if "sanitize" is false, do not sanitize
    #    otherwise
    #       sanitize
    #      
    if always_allow 
        return url
    else
      if !sanitize
        return url
      end
    end
    
    newurl = url
    
    # Look for the key terminated by "&"
    re=/&key=.+&/
    if re.match(url)
      newurl = url.gsub(re,'&key=hidden&')
    else
      # Look for key at the end of the url
      re=/&key=.+/
      if re.match(url)
        newurl = url.gsub(re,'&key=hidden')
      end
    end
      
    # Return the sanitized url.
    return newurl

  end
  
  
  def put_data_url
    url = url_for(:only_path => false, :host => request.host, :controller => 'measurements', :action => 'url_create', :instrument_id => @instrument.id)

    @instrument.vars.each do |var| 
      url +=  "&#{var.shortname}=#{var.name}"
    end

    url += "&at=2015-08-20T19:50:28"
    url += "&key=KeyValue"
    url += "&test"
    return url
  end
  
  def data_file_download_url(file_extension, range = nil)
    url = url_for(:only_path => false, :host => request.host, :controller => 'instruments', :action => 'show', :id => @instrument.id)
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
    
    logger.debug("**************************")
    logger.debug(@profile.secure_data_entry)
    # add the security key
    if @profile.secure_data_entry == true 
      url_fragment = "&key=" + @profile.data_entry_key
    end

    return url_fragment
  end

end
