class Instrument < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  
  belongs_to :site
  has_many :measurements, :dependent => :destroy
  has_many :vars, :dependent => :destroy
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
  
  def last_time_in_ms
    latest_point = GetLastTsPoint.call(TsPoint, 'value', self.id)

    if(defined? latest_point.to_a.first['time'])
      latest_time_ms = Time.parse(latest_point.to_a.first['time'])
    else
      latest_time_ms = Time.now
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


  def last_measurement
    measurement = Measurement.where("instrument_id = ?", self.id).order(:measured_at).last

    return measurement
  end

  def self.last_measurement_url
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
    if (self.sample_rate_seconds >= 1) 
      refresh_rate_ms           = self.sample_rate_seconds*1000
    else
      refresh_rate_ms = 1000
    end

    return refresh_rate_ms
  end
  
  def data(count, parameter)

    measurements = Measurement.where("instrument_id = ? and parameter = ?", self.id, parameter).last(self.display_points)
    
    data = Array.new    
    measurements.each do |measurement|
      t = Time.new(measurement.measured_at.year, measurement.measured_at.month, measurement.measured_at.day, measurement.measured_at.hour, measurement.measured_at.min, measurement.measured_at.sec, "+00:00")

      x=((t.to_i) * 1000).to_s
      data.push "[#{x}, #{measurement.value}]" 
      
    end

    return data.join(', ')
    
  end
        
end
