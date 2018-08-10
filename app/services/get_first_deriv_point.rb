class GetFirstDerivPoint
  # Return the first time series derivative point.
  
  # time_series_db - the database.
  # field          - the field to query for..
  # inst_id        - the instrument id.
  def self.call(time_series_db, field, inst_id)

        # first the first time series point
    ts_point = time_series_db \
      .select("*") \
      .where("inst = '#{inst_id}'") \
      .order("asc") \
      .limit(1)

    # get the var id for last time series point
    var_id = ts_point["var"]

    deriv_point = time_series_db \
      .select('derivative("value", 5m)') \
      .where("inst = '#{inst_id}") \
      .where("var = '#{var_id}") \
      .order("asc")
      .limit(1)

    return deriv_point
  end
end