class Instrument < ActiveRecord::Base
  belongs_to :site
  has_many :measurements
  
  def self.initialize
    Instrument.create([{name: 'Campbell', site_id:'1', }])
    Instrument.create([{name: 'Campbell', site_id:'2', }])
    Instrument.create([{name: 'Campbell', site_id:'3', }])

    Instrument.create([{name: '449 Profiler', site_id:'2', }])

    Instrument.create([{name: '915 Profiler', site_id:'1', }])
    Instrument.create([{name: '915 Profiler', site_id:'3', }])    
  end


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |rails_model|
        csv << rails_model.attributes.values_at(*column_names)
      end
    end
  end
      
end
