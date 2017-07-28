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
  

  def self.get_cuahsi_sites
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/GetSitesJSON"
    return JSON.parse(CuahsiHelper::send_request(uri_path, "").body)
  end

  def self.get_cuahsi_sitecode
    sites = get_cuahsi_sites
    code = sites.count
    return code + 1
  end

  def self.get_cuahsi_siteid(name)
    sites = get_cuahsi_sites
    id = sites.find {|site| site['SiteName']==name}
    if id != nil
      return id["SiteID"]
    end
    return id
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
      "SiteCode" => s.cuahsi_site_code,
      "Latitude" => s.lat,
      "Longitude" => s.lon,
      "SiteType" => s.site_type.name,
      "Elevation_m" => s.elevation
      }
	  return data
	end
  
end