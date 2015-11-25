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
end
