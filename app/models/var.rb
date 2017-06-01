class Var < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :measured_property

  before_destroy :delete_ts_points
  
  def measured_at_parameter
    return self.shortname + '_measured_at'
  end

  def at_parameter
    return self.shortname + '_at'
  end

  def random_value(previous_value = nil)

    # the maximum percent a previous value can change
    maximum_percent_change = 0.05
    
    # the number of decimal places to return
    precision = 2
    
    # default min/max values
    minimum = 0
    maximum = 100
    

    # set a min/max if the are devined for this variable
    if self.minimum_plot_value
      minimum = self.minimum_plot_value
    end

    if self.maximum_plot_value
      maximum = self.maximum_plot_value
    end

    # if a previous value exists, adjust that value +/- withing the percentage range
    if previous_value
      maximum_change = ((maximum - minimum)*(maximum_percent_change))

      # set the possible min/max range for the change
      local_minimum = (previous_value - maximum_change)
      local_maximum = (previous_value + maximum_change)

      # set the new random cvalue
      change = maximum_change/2 - rand(maximum_change)
      random_value = previous_value + change

      # make sure the returned values are still within the min/max bounds
      # if not, adjust accordingly
      if (random_value < minimum)
        random_value =  previous_value - change
      end

      if (random_value > maximum)
        random_value =  previous_value - change
      end

    else 
      random_value = (minimum + rand(maximum)).to_f
    end

    return random_value.round(precision)
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


  def delete_ts_points

    DeleteVariableTsPoints.call(TsPoint, self)
  end

end
