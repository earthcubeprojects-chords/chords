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
  
end
