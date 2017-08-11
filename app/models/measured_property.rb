class MeasuredProperty < ActiveRecord::Base
  has_many :vars

  # with defferent sources we have to allow duplicate names
  # validates :name, uniqueness: { case_sensitive: false }
  # validates :label, uniqueness: { case_sensitive: false }

  def self.populate
    self.populate_sendorml_measured_properties
    self.populate_cuahsi_variable_names
  end
  
  # SernsorML Measured Properties
  def self.populate_sendorml_measured_properties
    xml_file = Rails.root + 'lib/assets/sensorml_measures_properties.xml'
    
    doc = File.open(xml_file) { |f| Nokogiri::XML(f) }
    
    doc.xpath('//rdf:RDF').each do |node|
        node.children.each do |child_node| 
          if (child_node.name == 'Property')

            params = Hash.new

            child_node.children.each do |property_node| 

              case property_node.name
                when 'dc_title'
                  params['name'] = property_node.text
                when 'skos_prefLabel'            
                  params['label'] = property_node.text
                when 'skos_definition'
                  params['definition'] = property_node.text
              end
            end
            
            params['url'] = child_node.attribute('about').value
            params['source'] = 'SensorML'
            MeasuredProperty.create(params)
          end
        end
    end

  end
  
  # CUAHSI Measured Properties
  # This a derived subset of the CUAHSI VariableName Controlled Vocabulary as genereated by Hydroserver Lite
  def self.populate_cuahsi_variable_names

    csv_file_path = Rails.root + 'lib/assets/cuashi_variable_names_measured_properties.csv'

    puts csv_file_path
    
		csv_text = File.read(csv_file_path)
		csv = CSV.parse(csv_text, :headers => true)
		
		csv.each do |row|
			fields = row.to_hash
			
			measured_property = MeasuredProperty.new
			measured_property.name = fields["name"]
			measured_property.label = fields["name"]
			measured_property.url = 'http://hiscentral.cuahsi.org/webservices/hiscentral.asmx/getOntologyTree'
			measured_property.definition = fields["definition"]
			measured_property.source = "CUAHSI"
      measured_property.save
		end


  	
  	
  end
end
