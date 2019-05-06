class Instrument < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :site

  has_many :vars, dependent: :destroy
  has_many :influxdb_tags, dependent: :destroy

  belongs_to :topic_category

  accepts_nested_attributes_for :vars

  def self.initialize
  end

  def to_s
    name
  end

  def select_label
    "#{site.name}: #{name}"
  end

  def find_var_by_shortname (shortname)
    var_id = Var.all.where("instrument_id='#{self.id}' and shortname='#{shortname}'").pluck(:id)[0]

    if var_id
      return Var.find(var_id)
    else
      return nil
    end
  end

  # Returns the time of first or last measurement given parameter point ("first" or "last")
  def point_time_in_ms(point)
    if point == "last"
      latest_point = GetLastTsPoint.call(TsPoint, 'value', self.id)
    else
      latest_point = GetFirstTsPoint.call(TsPoint, 'value', self.id)
    end

    if(defined? latest_point.to_a.first['time'])
      latest_time_ms = Time.parse(latest_point.to_a.first['time'])
    else
      latest_time_ms = "None"
    end

    return latest_time_ms
  end

  # # Returns the time of the first or last derivative calculation given parmeter point ("first" or "last")
  # def deriv_time_in_ms(point)
  #   if point == "last"
  #     latest_deriv = GetLastDerivPoint.call(TsPoint, 'value', self.id)
  #   else
  #     first_deriv = GetFirstDerivPoint.call(TsPoint, 'value', self.id)
  #   end

  #   if (defined? latest_deriv.to_a.first['time'])
  #     latest_deriv_time = Time.parse(latest_deriv.to_a.first['time'])
  #   else
  #     latest_deriv_time = "None"
  #   end

  #   return latest_deriv_time
  # end

  # get the downsampling rate for influx query
  def downsample_rate (starttime, endtime, var_id)
    max_points = self.maximum_plot_points

    if endtime == nil
      count = TsPoint \
        .count("value") \
        .where(inst: self.id) \
        .where(var: var_id) \
        .since(starttime)
    else
      count = TsPoint \
        .count("value") \
        .where(inst: self.id) \
        .where(var: var_id) \
        .where(time: starttime..endtime)
    end

    num_points = count.to_a[0]["count"].to_i

    if num_points > max_points
      rate = (num_points.to_f / max_points).ceil * self.sample_rate_seconds
      return rate
    else
      return self.sample_rate_seconds
    end
  end

  # return the maximum number of points per variable to render => 180
  # TODO: add option for user input when setting env variables
  def maximum_plot_points
    return 180
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names

      all.each do |rails_model|
        csv << rails_model.attributes.values_at(*column_names)
      end
    end
  end

  def self.data_insert_url
    url = instrument_url()
  end

  def is_receiving_data
    if defined? TsPoint
      return IsTsInstrumentAlive.call(TsPoint, "value", self.id, self.sample_rate_seconds+5)
    else
      return false
    end
  end

  def last_age
    if defined? TsPoint
      return GetLastTsAge.call(TsPoint, "value", self.id)
    else
      return false
    end
  end

  def sample_count(sample_type)
    case sample_type
    when :not_test
      measurement_count
    when :test
      measurement_test_count
    else
      measurement_count + measurement_test_count
    end
  end

  def refresh_rate_ms
    # Limit the chart refresh rate
    if self.sample_rate_seconds >= 1
      refresh_rate_ms = self.sample_rate_seconds*1000
    else
      refresh_rate_ms = 1000
    end

    return refresh_rate_ms
  end

  def influxdb_tags_hash
    influxdb_tags = Hash.new

    self.influxdb_tags.each do |influxdb_tag|
      influxdb_tags[influxdb_tag.name] = influxdb_tag.value
    end

    return influxdb_tags
  end

  def instrument_url
    p = Profile.first
    link = p.domain_name + "/instruments/" + self.id.to_s
    return link
  end

  def current_day_download_link(type)
    '/api/v1/data/' + self.id.to_s + ".#{type.to_s}"
  end
end
