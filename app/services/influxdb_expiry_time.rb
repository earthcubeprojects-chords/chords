class InfluxdbExpiryTime
  # Return the date when a specified retention policy expires.
  # Return is a string
  def self.call(policyName)
    
    result = "unknown"
    
    retentionQuery = "show retention policies"
    queryresult = Influxer.client.query(retentionQuery) 

    if queryresult.length > 0
      queryresult.to_a[0]["values"].each do |v|

        # look for the desired policy
        if v["name"] == policyName
          # duration has the form "12h35m21s"
          duration = v["duration"]
          
          # split the duration into array [s, m, h]. It might only
          # contain seconds, or seconds and minutes.
          time_parts = duration.split(/[hms]/).reverse.map{ |d| d.to_i }

          # convert the duration to seconds
          if time_parts.length > 0
            seconds = time_parts[0]
            if time_parts.length > 1
              seconds = seconds + time_parts[1] * 60
              if time_parts.length > 2
                seconds = seconds + time_parts[2] * 60 * 60
              end
            end
            
            if seconds == 0
              result = "never"
            else 
              # Calulate the date that preceeds now.
              result_date = seconds.seconds.ago
              # format it
              result = result_date.strftime("%Y-%m-%d")
            end
          end
        end
      end
    end
    
    return result
  end
end
