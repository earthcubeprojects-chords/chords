class GetTsCountsByInterval
  # Return the non-zero counts of a time series data field, binned by a 
  # time resolution and segregated by instrument.
  #
  # time_series_db - the database
  # end_time       - the end time of the time interval
  # field          - the series data field to count
  # span_s         - the length of time to span
  # resolution     - the interval for time grouping, e.g "1m", "4h", "1d", etc.
  # inst_ids       - the collection of all instrument ids (even ones without data)
  #
  # Return the times/counts in the following hash/array structure.
  # {
  #   1=>[
  #        [1478476800000, 7634], 
  #        [1478563200000, 14516]
  #        ...
  #      ], 
  #   2=>[
  #        [1478476800000, 7608], 
  #        [1478563200000, 14250]], 
  #        ...
  #      ]
  # }
  #
  # Notes:
  #  Times are returned in ms resolution.
  #  If there is no counts for an instrument, there will be an empty array.
  #  Only non-zero counts will be returned.
  #  The timetags for one instrument can be different than those of another instrument.  
  def self.call(time_series_db, end_time, span_s, resolution, field, inst_ids)
    # 
    # set the time endpoints
    span_ns = span_s*1000000000
    end_time_ns   = (end_time.to_f*1000000000).to_i
    begin_time_ns = end_time_ns - span_ns

    # query database
    counts = time_series_db \
      .select("count(#{field})") \
      .where("time > #{begin_time_ns} and time <= #{end_time_ns}") \
      .group(:inst).time("#{resolution}")
    #
    # Returned values from time)series_db are structured as folows:
    # [
    #   {"time"=>"2016-09-09T00:00:00Z", "count"=>567, "inst"=>"1"}, 
    #   {"time"=>"2016-09-10T00:00:00Z", "count"=>0,   "inst"=>"1"},
    #    ...
    #   {"time"=>"2016-09-18T00:00:00Z", "count"=>880, "inst"=>"4"}
    # ]
    #

    # Create a hash to hold the results by instrument,
    # and create empty arrays.
    count_series = {}
    inst_ids.each do |id| 
      count_series[id.to_i] = []
    end
    
    # Assign each data record to a count array
    counts.each do |count_record|
      c = count_record["count"]
      if c != 0 
        t = ConvertIsoToMs.call(count_record["time"])
        value = [t, c]
        count_series[count_record["inst"].to_i].append(value)
      end
    end
    
    return count_series
  end
  
end