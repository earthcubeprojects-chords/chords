class TopicCategory < ActiveRecord::Base
  has_many :instruments

	validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :definition, presence: true, uniqueness: { case_sensitive: false }

  def self.populate
  	xml_file = Rails.root + 'lib/assets/topic_categories.xml'
    doc = File.open(xml_file) { |f| Nokogiri::XML(f) }
    # puts doc.xpath("//Record")
    doc.xpath("//Record").each do |node|
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
	
	
  
  def self.list_topic_category_options 
    TopicCategory.select("id, name").map {|topic_category| [topic_category.id, topic_category.name] }
  end	


end
