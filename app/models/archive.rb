class Archive < ActiveRecord::Base

  def self.initialize
    Archive.create([{
      name: 'none',
      base_url: '', 
      send_frequency: '',
      last_archived_at: nil
    }])      
  end

end
