include ActionView::Helpers::DateHelper

class Measurement < ActiveRecord::Base
  belongs_to :instrument


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |rails_model|
        csv << rails_model.attributes.values_at(*column_names)
      end
    end
  end


  def json_point
    time = Time.new(self.created_at.year, self.created_at.month, self.created_at.day, self.created_at.hour, self.created_at.min, self.created_at.sec, "+00:00")
    milliseconds = ((time.to_i) * 1000).to_s

    #create an array and echo to JSON
    ret =[milliseconds.to_i, self.value]
    
    json = ActiveSupport::JSON.encode(ret)
    
    return json    
  end
  
  def age
    time_ago_in_words(self.created_at)
  end
  
end


