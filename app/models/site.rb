class Site < ActiveRecord::Base
  has_many :instruments, :dependent => :destroy
  
  def self.initialize
  end
  
  def self.list_site_options 
    Site.select("id, name").map {|site| [site.id, site.name] }
  end  
  
  def self.get_cuahsi_sitecode
  	uri = URI.parse("http://hydroportal.cuahsi.org/CHORDS/index.php/default/services/api/GetSitesJSON")

    request = Net::HTTP::Post.new uri.path

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
    puts response.body
    sites = JSON.parse(response.body)
    code = sites.count
    return code + 1
  end
  
end