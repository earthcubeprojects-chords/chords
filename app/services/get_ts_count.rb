class GetTsCount
  
  def self.call(time_series_db, field, inst_id, find_test=false)
    if !find_test
      counts = time_series_db.select("count(#{field})").where("inst = '#{inst_id}' and test  = 'false'")
    else
      counts = time_series_db.select("count(#{field})").where("inst = '#{inst_id}' and test  = 'true'")
    end
    Rails.logger.debug counts
    if counts.length > 0
      counts.each do |c|
        return c["count"]
      end
    end
    
    return 0
  end
end