class GetLastTsAge
  def self.call(time_series_db, field, inst_id)
    last_data = time_series_db.select("#{field}").where("inst = '#{inst_id}'").order("desc").limit(1)
    age = "never"
    if last_data.length > 0
      last_data.each do |l|
        last_data_time = Time.parse(l["time"])
        age = time_ago_in_words(last_data_time)
      end
    end
    
    return age
  end
end