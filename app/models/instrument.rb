require 'task_helpers/cuahsi_helper'

class Instrument < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include CuahsiHelper

  belongs_to :site

  has_many :vars, dependent: :destroy
  has_many :influxdb_tags, dependent: :destroy

  belongs_to :topic_category

  accepts_nested_attributes_for :vars

  def self.initialize
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

  def maximum_plot_points
    time_offset_seconds = eval("#{self.plot_offset_value}.#{self.plot_offset_units}")
    points_to_plot = time_offset_seconds / self.sample_rate_seconds

    return points_to_plot.to_i
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
    if defined? TsPoint
      return GetTsCount.call(TsPoint, "value", self.id, sample_type)
    else
      return 0
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

  def get_cuahsi_methods
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/GetMethodsJSON"
    return JSON.parse(CuahsiHelper::send_request(uri_path, "").body)
  end

  def get_cuahsi_methodid(method_link)
    if self.cuahsi_method_id
      return self.cuahsi_method_id
    else
      methods = get_cuahsi_methods
      id = methods.find {|method| method['MethodLink']==method_link}

      if id != nil
        self.cuahsi_method_id = id["MethodID"]
        self.save
        return self.cuahsi_method_id
      end

      return id
    end
  end

  def instrument_url
    p = Profile.first
    link = p.domain_name + "/instruments/" + self.id.to_s
    return link
  end

  def create_cuahsi_method
    data = {
      "user" => Rails.application.config.x.archive['username'],
      "password" => Rails.application.config.x.archive['password'],
      "MethodDescription" => self.name,
      "MethodLink" => instrument_url
      }
    return data
  end
end
