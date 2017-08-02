require 'csv'

class Unit < ActiveRecord::Base
    has_many :vars

    validates :name, uniqueness: false, presence: true
    validates_uniqueness_of :id_num, :scope => :source
		validates :unit_type, uniqueness: false
		validates :abbreviation, uniqueness: false, presence: true
		validates :source, uniqueness: false, presence: true

	def self.populate
		#populate CUAHSI units
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
            params['unit_type'] = property_node.text
          when 'UnitsAbbreviation'
          	params['abbreviation'] = property_node.text
	      end
	      params['source'] = "CUAHSI"
	    	Unit.create(params)
    	end
    end

    id_num = 1
    #populate UDUNITS
  	csv_file = Rails.root + 'lib/assets/udunits.csv'
		csv_text = File.read(csv_file)
		csv = CSV.parse(csv_text, :headers => true)
		csv.each do |row|
			fields = row.to_hash
			unit = Unit.new
			unit.name = fields["name"]
			unit.abbreviation = fields["abbreviation"]
			unit.source = "UDUNITS"
			unit.id_num = id_num
			unit.save
			id_num += 1
		end

	end

end
