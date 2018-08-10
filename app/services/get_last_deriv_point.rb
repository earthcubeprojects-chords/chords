class GetLastDerivPoint
  # Return the last derivative point.
  #
  # time_series_db - the database.
  # field          - the field to query for..
  # inst_id        - the instrument id.
  def self.call(time_series_db, field, inst_id)
    
    # first the last time series point
    ts_point = time_series_db \
      .select("*") \
      .where("inst = '#{inst_id}'") \
      .order("desc") \
      .limit(1)

    # get the var id for last time series point
    var_id = ts_point.to_a[0]["var"].to_i

    deriv_point = time_series_db \
      .select('derivative("value")') \
      .where("inst = '#{inst_id}'") \
      .where("var = '#{var_id}'") \
      .order("desc") \
      .limit(1)
    
    return deriv_point
  end  
end
