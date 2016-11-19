class GetLastTsPoint
  # Return the last time series point.
  #
  # time_series_db - the database.
  # field          - the field to query for..
  # inst_id        - the instrument id.
  def self.call(time_series_db, field, inst_id)
    
    ts_point = time_series_db \
      .select("*") \
      .where("inst = '#{inst_id}'") \
      .order(:desc) \
      .limit(1)
    
    return ts_point
  end  
end
