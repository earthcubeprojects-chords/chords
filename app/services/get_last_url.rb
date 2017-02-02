class GetLastUrl

  # Return the last create url for the instrument. If 
  # no instrument is specified, search all instruments.
  # nil is a possible return value.
  #
  # Note that this class references the Rails Instrument model. 
  def self.call(time_series_db, inst_id=nil)

    last_id = inst_id

    if !last_id
      # Find the instrument with the most recent timetag.

      # get the last points
      last_points = []
      Instrument.all.each do |inst| 
        last_point = GetLastTsPoint.call(time_series_db, 'value', inst.id).to_a
        last_points.push(last_point[0]) if last_point.length
      end
      
      if last_points.length == 0
        return nil
      end
      
      # sort by time
      last_points.sort_by! {|p| p["time"]}

      # Extract the most recent id
      if last_points.length > 0
        last_id = last_points.last["inst"]
      end
    end

    if last_id
      return Instrument.find(last_id).last_url
    end

    return nil

  end
end
