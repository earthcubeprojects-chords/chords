class Instrument < ActiveRecord::Base
  belongs_to :site
  has_many :measurements, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  accepts_nested_attributes_for :vars
  
  def self.initialize
#    Instrument.create([{name: 'Campbell', site_id:'1', }])
#    Instrument.create([{name: 'Campbell', site_id:'2', }])
#    Instrument.create([{name: 'Campbell', site_id:'3', }])

#    Instrument.create([{name: '449 Profiler', site_id:'2', }])

#    Instrument.create([{name: '915 Profiler', site_id:'1', }])
#    Instrument.create([{name: '915 Profiler', site_id:'3', }])    
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
    measurement = Measurement.where("instrument_id = ?", self.id).order(:created_at).last
    # logger.debug()
    return measurement
  end
  
  def is_receiving_data
    measurement = Measurement.where("(instrument_id = ?) AND (created_at > ?)", self.id, self.seconds_before_timeout.seconds.ago).order(:created_at).last

    if measurement
      return TRUE
    else
      return FALSE
    end
    
  end
  


  def data(count)

    measurements = Measurement.where("instrument_id = ?", self.id).last(self.display_points)
    
    data = Array.new    
    measurements.each do |measurement|
      t = Time.new(measurement.created_at.year, measurement.created_at.month, measurement.created_at.day, measurement.created_at.hour, measurement.created_at.min, measurement.created_at.sec, "+00:00")

      x=((t.to_i) * 1000).to_s
      data.push "[#{x}, #{measurement.value}]" 
      
    end

    return data.join(', ')
    
  end
      
end
