class Site < ActiveRecord::Base
  require 'task_helpers/cuahsi_helper'
  include CuahsiHelper

  has_many :instruments, :dependent => :destroy
  belongs_to :site_type
  
  def self.initialize
  end
  
  def self.list_site_options 
    Site.select("id, name").map {|site| [site.id, site.name] }
  end  
  

  def get_cuahsi_sites
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/GetSitesJSON"
    return JSON.parse(CuahsiHelper::send_request(uri_path, "").body)
  end

  def get_cuahsi_sitecode
    sites = get_cuahsi_sites
    code = sites.count
    return code + 1
  end

  def get_cuahsi_siteid
    if self.cuahsi_site_id
      return self.cuahsi_site_id 
    else
      find_site
    end
  end

  def find_site
    sites = get_cuahsi_sites
    id = sites.find {|site| site['SiteName']==self.name}
    if id != nil
      self.cuahsi_site_id = id["SiteID"]
      self.save
      return id["SiteID"]
    end
    return id
  end


  def create_cuahsi_site
    profile = Profile.first
    url = profile.domain_name
  	
  	if self.cuahsi_site_code == nil
  	  self.cuahsi_site_code = get_cuahsi_sitecode
  	  self.save
	  end
	  
	  data = {
      "user" => Rails.application.config.x.archive['username'],
      "password" => Rails.application.config.x.archive['password'],
      "SourceID" => profile.get_cuahsi_sourceid(url),
      "SiteName" => self.name,
      "SiteCode" => self.cuahsi_site_code,
      "Latitude" => self.lat,
      "Longitude" => self.lon,
      "SiteType" => self.site_type.name,
      "Elevation_m" => self.elevation
      }
	  return data
	end
  
end