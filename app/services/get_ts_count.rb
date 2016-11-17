class GetTsCount
  
  # find_test: :test, :not_test, :either
  def self.call(time_series_db, field, inst_id, find_test=:either)
    case find_test
    when :not_test
      counts = time_series_db.select("count(#{field})").where("inst = '#{inst_id}' and test  = 'false'")
    when :test
      counts = time_series_db.select("count(#{field})").where("inst = '#{inst_id}' and test  = 'true'")
    else
      counts = time_series_db.select("count(#{field})").where("inst = '#{inst_id}'")
    end
    if counts.length > 0
      counts.first["count"]
    end
    
    return 0
  end
end