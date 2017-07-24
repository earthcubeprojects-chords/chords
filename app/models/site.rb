class Site < ActiveRecord::Base
  has_many :instruments, :dependent => :destroy
  belongs_to :site_type
  
  def self.initialize
  end
  
  def self.list_site_options 
      Site.select("id, name").map {|site| [site.id, site.name] }
  end  
  
  
end
