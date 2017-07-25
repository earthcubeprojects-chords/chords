class Archive < ActiveRecord::Base

  def self.initialize
    Archive.create([{
      name: 'none',
      base_url: '', 
      send_frequency: '',
      last_archived_at: nil
    }])      
  end


  def self.name_options
    options = { :none =>  'none', :CUAHSI => 'CUAHSI' }
  end
  
  
  def self.send_frequency_options
    
    options = Hash.new
    options['1.months'] = 'every month'
    options['1.weeks'] = 'every week'
    options['1.days'] = 'every day'
    options['6.hours'] = 'every 6 hours'
    options['1.hours'] = 'every hour'
    options['15.minutes'] = 'every 15 minutes'
    options['5.minutes'] = 'every 5 minutes'
    options['1.minutes'] = 'every minute'
    
    return options
  end
end
