class Site < ActiveRecord::Base
  has_many :instruments, :dependent => :destroy
  
  def self.initialize
  end
  
  def self.list_site_options 
      Site.select("id, name").map {|site| [site.id, site.name] }
  end  
  
  
  def destroy
    
    # Destroy instruments first
    self.instruments.each do |instrument|
      instrument.destroy
    end
    
    super.destroy
  end
end
