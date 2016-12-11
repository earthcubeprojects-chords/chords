class GetLastUrl
  
  def self.call(time_series_db, inst_id=nil)
    
    Rails.logger.debug 'GetLastUrl' 

    if inst_id 
      return Instrument.find(inst_id).last_url
    end
    
    Instrument.all.each do |inst|
      id = inst.id
      last_point = GetLastTsPoint.call(time_series_db, 'value', id)
      Rails.logger.debug 'GetLastUrl: instrument ' + inst.id.to_s + " " + last_point.to_a.to_s
    end
    
    return nil
  end
end
