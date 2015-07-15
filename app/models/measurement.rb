include ActionView::Helpers::DateHelper

class Measurement < ActiveRecord::Base
  belongs_to :instrument


  def self.to_csv(inst_name, varnames, options = {})
  
    # Upon entry, we contain the measurements of interest (i.e.
    # they have been time and instrument selected.
    
    # Create a vector of unique times
    times = self.pluck(:created_at).uniq.sort
    
    # Collect the CSV column titles from varnames
    column_titles = []
    column_titles << "Time" << "Instrument Name"
    varnames.each {|v| column_titles << v[1]}
    
    # Extract the Var time and data value for each varshortname.
    # Each entry in vardata will be a hash, where the keys will be the
    # timestamp, and the value will be the measurement value.
    vardata = {}
    varnames.keys.each do |shortname|
      vararrays = self.where("parameter = ?", shortname).pluck(:created_at, :value)
      vardata[shortname] = {}
      vararrays.each do |v|
        vardata[shortname][v[0]] = v[1]
      end
    end
    
    # Create the csv file, with one column for each var
    CSV.generate(options) do |csv|
      csv << column_titles
      times.each do |t|
        row = []
        row << t
        row << inst_name
        varnames.keys.each do |shortname|
          vdata = vardata[shortname]
          # Nil values will create ',,'
          row << vdata[t]
        end
        csv << row
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


