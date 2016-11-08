class IsTsInstrumentAlive
  
  # Return true if recent data is available for an instrument
  #
  # 
  def self.call(time_series_db, field, inst_id, time_span_s)
    recent_data_count = time_series_db.select("count(#{field})").where("inst = '#{inst_id}'").past(time_span_s)

    if recent_data_count.length > 0
      return true
    else
      return false
    end
  end
end