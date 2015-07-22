class Site < ActiveRecord::Base
  has_many :instruments
  
  
  def self.initialize
#    Site.create([{name: 'ISS1 Lyons', lat: '40.2', lon:'-104.0'}])
#    Site.create([{name: 'ISS2 Sugarloaf', lat: '40.0', lon:'-104.1'}])
#    Site.create([{name: 'ISS3 Nederland', lat: '39.9', lon:'-104.3'}])
  end
  
  def self.list_site_options 
      Site.select("id, name").map {|site| [site.id, site.name] }
  end  
end
