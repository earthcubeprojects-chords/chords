require 'nokogiri'

class MakeXmlFromTsPoints
  def self.call(ts_points, metadata)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.notice "XML formatted data is currently not available"
      }
    end
    builder.to_xml
  end
  
end