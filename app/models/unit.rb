require 'csv'

class Unit < ActiveRecord::Base
    has_many :vars

		validates :name, uniqueness: { case_sensitive: false }


	def self.populate
		xml_file = Rails.root + 'lib/assets/cuahsi_units.xml'
  	doc = File.open(xml_file) { |f| Nokogiri::XML(f) }
  	doc.xpath("//x:Record", {"x" => "http://his.cuahsi.org/his/1.1/ws/"}).each do |node|
      params = Hash.new
      node.children.each do |property_node| 
      	case property_node.name
            when 'UnitsID'
              params['id_num'] = property_node.text
            when 'UnitsName'            
              params['name'] = property_node.text
            when 'UnitsType'            
              params['type'] = property_node.text
            when 'UnitsAbbreviation'
            	params['abbreviation'] = property_node.text
       	end
    	Unit.create(params)
    	end
    end
	end

end
