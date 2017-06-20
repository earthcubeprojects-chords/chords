class TopicCategory < ActiveRecord::Base
	has_and_belongs_to_many :instruments

	validates :name, uniqueness: { case_sensitive: false }
  	validates :definition, uniqueness: { case_sensitive: false }

  	def self.populate
  		xml_file = Rails.root + 'lib/assets/topic_categories.xml'
    	doc = File.open(xml_file) { |f| Nokogiri::XML(f) }
    	doc.xpath("//x:Record", {"x" => "http://his.cuahsi.org/his/1.1/ws/"}).each do |node|
            params = Hash.new
            node.children.each do |property_node| 
            	case property_node.name
	                when 'Term'
	                  params['name'] = property_node.text
	                when 'Definition'            
	                  params['definition'] = property_node.text
             	end
        	TopicCategory.create(params)
        	end
	    end
	end


end
