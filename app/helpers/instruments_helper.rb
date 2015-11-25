module InstrumentsHelper
  def self.sanitize_url(always_allow, sanitize, url)
    # if allways_allow is true, do not sanitize
    # otherwise
    #  if do_sanitize is false, do not sanitize
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
      
    return newurl

  end
end
