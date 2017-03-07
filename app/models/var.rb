class Var < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :measured_property

  def measured_at_parameter
    return self.shortname + '_measured_at'
  end

  def at_parameter
    return self.shortname + '_at'
  end

  def get_tspoints (since, display_points = self.instrument.display_points)
    # Get the measurements
    # TODO: use the :after parameter. It did not interact correctly with
    # the highchart during prototyping. The problem may be on the javascript side.
    ts_points = TsPoint \
      .where("inst = '#{self.instrument.id}'") \
      .where("var  = '#{self.id}'") \
      .order("desc") \
      .since(since) 
      
    ts_points = ts_points.to_a
    live_points = []
    if ts_points
      # Collect the times and values for the measurements
      
      ts_points.reverse_each do |p| 
        live_points  << [ConvertIsoToMs.call(p["time"]), p["value"].to_f]
      end
      
    end

    return live_points
  end


end
