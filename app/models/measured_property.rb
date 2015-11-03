class MeasuredProperty < ActiveRecord::Base
  has_many :vars
  
  validates :name, uniqueness: { case_sensitive: false }
  validates :label, uniqueness: { case_sensitive: false }

  def self.populate
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
            MeasuredProperty.create(params)
          end
        end
    end
  end
end
