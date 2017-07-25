class Site < ActiveRecord::Base
  has_many :instruments, :dependent => :destroy
  belongs_to :site_type
  
  def self.initialize
  end
  
  def self.list_site_options 
      Site.select("id, name").map {|site| [site.id, site.name] }
  end  
  
  def self.create_cuahsi_site(site_id)
    profile = Profile.find(1)
    url = profile.domain_name
  	s = Site.find(site_id)
	  data = {
      "user" => Rails.application.config.x.archive['username'],
      "password" => Rails.application.config.x.archive['password'],
      "SourceID" => Profile.get_cuahsi_sourceid(url),
      "SiteName" => s.name,
      "SiteCode" => 1,
      "Latitude" => s.lat,
      "Longitude" => s.lon,
      "SiteType" => "Stream",
      "Elevation_m" => s.elevation
      }
	  return data
	end
  
end
