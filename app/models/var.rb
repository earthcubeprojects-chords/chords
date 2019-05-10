class Var < ApplicationRecord
  belongs_to :instrument
  belongs_to :measured_property
  belongs_to :unit

  before_destroy :delete_ts_points

  validate :check_plot_range_valid

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


  def get_tspoints (starttime, endtime, display_points = self.instrument.display_points)
    if (endtime == nil)
    # if there is no end time, get downsampled data from start to most recent data
      downsample_rate = self.instrument.downsample_rate(starttime, nil, self.id)
      ts_points = TsPoint \
        .mean(:value) \
        .where(inst: self.instrument.id) \
        .where(var: self.id) \
        .time(downsample_rate.to_s + "s") \
        .order("desc") \
        .since(starttime)
    else
    # otherwise, get data from start to end
      downsample_rate = self.instrument.downsample_rate(starttime, endtime, self.id)
      ts_points = TsPoint \
        .mean(:value) \
        .where(inst: self.instrument.id) \
        .where(var: self.id) \
        .where(time: starttime..endtime) \
        .time(downsample_rate.to_s + "s") \
        .order("desc")
    end

    ts_points = ts_points.to_a
    live_points = []
    if ts_points
      # Collect the times and values for the measurements
      ts_points.reverse_each do |p|
        if (p["mean"]) && (p["mean"].to_f != 0.0)
          live_points  << [ConvertIsoToMs.call(p["time"]), p["mean"].to_f]
        elsif (p["value"])
          live_points  << [ConvertIsoToMs.call(p["time"]), p["value"].to_f]
        end
      end
    end

    return live_points
  end

  def delete_ts_points
    DeleteVariableTsPoints.call(TsPoint, self)
  end

  def self.get_general_categories_collection
    category_names = ['Unknown', 'Biota', 'Chemistry', 'Climate', 'Geology', 'Hydrology', 'Instrumentation', 'Limnology', 'Soil', 'Water Quality']

    general_categories = Hash[category_names.map {|name| [name, name]}]

    return general_categories
  end

  private

  def check_plot_range_valid
    if minimum_plot_value && maximum_plot_value
      if minimum_plot_value > maximum_plot_value
        errors.add(:minimum_plot_value, 'must be less than maximum_plot_value')
        errors.add(:maximum_plot_value, 'must be greater than minimum_plot_value')
      end
    end
  end
end
