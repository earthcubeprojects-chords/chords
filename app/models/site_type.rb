class SiteType < ActiveRecord::Base

	validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :definition, presence: true, uniqueness: { case_sensitive: false }

	def self.populate
		xml_file = Rails.root + 'lib/assets/site_types.xml'
  	doc = File.open(xml_file) { |f| Nokogiri::XML(f) }
  	doc.xpath("//Record").each do |node|
      params = Hash.new
      node.children.each do |property_node| 
      	case property_node.name
            when 'Term'
              params['name'] = property_node.text
            when 'Definition'            
              params['definition'] = property_node.text
       	end
    	SiteType.create(params)
    	end
    end
	end


end
