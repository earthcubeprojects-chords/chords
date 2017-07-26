
class GetFirstTsPoint
  # Return the last time series point.
  #
  # time_series_db - the database.
  # field          - the field to query for..
  # inst_id        - the instrument id.
  def self.call(time_series_db, field, inst_id=nil)
    
    # if not instrument id is specified, return the first point in the entire series
    if (inst_id == nil)
      ts_point = time_series_db \
        .select("*") \
        .order("asc") \
        .limit(1)

    # if instrument id is set, return the first point for that instrument
    else
      ts_point = time_series_db \
        .select("*") \
        .where("inst = '#{inst_id}'") \
        .order("asc") \
        .limit(1)      
    end
    
    return ts_point
  end  
end