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
      
end
