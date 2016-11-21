class GetTsPoints
  # Return the time series points within the specified time interval. 
  # An array of points will be returned.
  #
  # time_series_db - the database.
  # field          - the field to return.
  # inst_id        - the instrument id.
  # start_time     - beginning time stamp. Times greater or equal will be returned
  # end_time       - the end time. Times less than this will be returned..
  def self.call(time_series_db, field, inst_id, start_time, end_time)
    
    start_time_ns = (start_time.to_f*1000000000).to_i
    end_time_ns   = (end_time.to_f*1000000000).to_i
    
    # See if a single timestamp has been requested.
    if start_time_ns != end_time_ns
      time_query = "time >= #{start_time_ns} and time < #{end_time_ns}"
    else
      time_query = "time = #{start_time_ns}"
    end
    
    ts_points = time_series_db \
      .select("*") \
      .where("inst = '#{inst_id}'") \
      .where(time_query) \
      .group("var")
    
    return ts_points.to_a
    
  end
end