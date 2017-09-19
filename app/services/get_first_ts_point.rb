
class GetFirstTsPoint
  # Return the first time series point.
  # if no instrument id is specified, return 
  # the first point for all instruments.
  #
  # time_series_db - the database.
  # field          - the field to query for..
  # inst_id        - the instrument id.
  def self.call(time_series_db, field, inst_id=nil)
    
    if (inst_id == nil)
      # if not instrument id is specified, return the first point in the entire series
      ts_point = time_series_db \
        .select("*") \
        .order("asc") \
        .limit(1)
    else
      # if instrument id is set, return the first point for that instrument
      ts_point = time_series_db \
        .select("*") \
        .where("inst = '#{inst_id}'") \
        .order("asc") \
        .limit(1)      
    end
    
    return ts_point
  end  
end