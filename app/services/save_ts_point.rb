class SaveTsPoint
  
  def self.call(time_series_db, args)
    point = time_series_db.new(args)
    point.write
  end
end