
class GetFirstTsPoint
  # Return the last time series point.
  #
  # time_series_db - the database.
  # field          - the field to query for..
  # inst_id        - the instrument id.
  def self.call(time_series_db, field, inst_id=nil)
    
    if (inst_id == nil)
      ts_point = time_series_db \
        .select("*") \
        .order("asc") \
        .limit(1)

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