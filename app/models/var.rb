require 'task_helpers/cuahsi_helper'

class Var < ActiveRecord::Base
  include CuahsiHelper

  belongs_to :instrument
  belongs_to :measured_property
  belongs_to :unit

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

# def get_tsderivatives (starttime, endtime, display_points = self.instrument.display_points)

#   if (endtime == nil)
#     ts_derivatives = TsPoint \
#       .select('derivative("value")') \
#       .where(inst: self.instrument.id) \
#       .where(var: self.id) \
#       .order("desc") \
#       .since(starttime)
#   else 
#     ts_derivatives = TsPoint \
#       .select('derivative("value")') \
#       .where(inst: self.instrument.id) \
#       .where(var: self.id) \
#       .where(time: starttime..endtime) \
#       .order("desc")
#   end

#   ts_derivatives = ts_derivatives.to_a
#   derivatives = []
#   if ts_derivatives
#     ts_derivatives.reverse_each do |p|
#       derivatives << [ConvertIsoToMs.call(p["time"]), p["derivative"].to_f]
#     end
#   end

#   return derivatives
# end


  def delete_ts_points
    DeleteVariableTsPoints.call(TsPoint, self)
  end

  def self.get_general_categories_collection
    category_names = ['Unknown', 'Biota', 'Chemistry', 'Climate', 'Geology', 'Hydrology', 'Instrumentation', 'Limnology', 'Soil', 'Water Quality']

    general_categories = Hash[category_names.map {|name| [name, name]}]

    return general_categories
  end

  def get_cuahsi_variables
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/GetVariablesJSON"
    return JSON.parse(CuahsiHelper::send_request(uri_path, "").body)
  end

  def get_cuahsi_variableid(variable_code)
    if self.cuahsi_variable_id
      return self.cuahsi_variable_id
    else
      variables = get_cuahsi_variables
      id = variables.find {|variable| variable['VariableCode']==variable_code.to_s}
      if id != nil
        self.cuahsi_variable_id = id["VariableID"]
        self.save
        return self.cuahsi_variable_id
      end
      return id
    end
  end


  def create_cuahsi_variable
    data = {
      "user" => Rails.application.config.x.archive['username'],
      "password" => Rails.application.config.x.archive['password'],
      "VariableCode" => Profile.first.domain_name + ':' + self.instrument.site.id.to_s + ":" + self.instrument.id.to_s + ":" + self.id.to_s,
      "VariableName" => self.measured_property.name,
      "Speciation" => "Not Applicable",
      "VariableUnitsID" => self.unit.id_num,
      "SampleMedium"=> "Unknown",
      "ValueType" => "Sample",
      "IsRegular" => 1,
      "TimeSupport" => self.instrument.sample_rate_seconds,
      "TimeUnitsID" => 100,
      "DataType" => "Unknown",
      "GeneralCategory" => self.general_category,
      "NoDataValue" => -9999
      }
    return data
  end
end
