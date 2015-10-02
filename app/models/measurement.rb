include ActionView::Helpers::DateHelper

class Measurement < ActiveRecord::Base
  belongs_to :instrument

  def self.to_csv(metadata, varnames, options = {})
  
    # Upon entry, we contain the measurements of interest (i.e.
    # they have been time and instrument selected.
    
    # Fetch the desired data. A hash is returned. It contains
    # an entry "Time", with data times, and entries for each of the 
    # varnames.
    vardata = MeasurementsHelper.columnize(self, varnames)
    
    # Get the time values
    times = vardata["Time"].values.sort
    
    # Collect the CSV column titles from varnames
    column_titles = []
    column_titles << "Time"
    varnames.each {|v| column_titles << v[1]}
    
    # Create the csv file, with one column for each var
    CSV.generate(options) do |csv|
      # Put the metadata at the head of the file, one line per group
      metadata.each do |line|
        csv << line
      end
      csv << column_titles
      times.each do |t|
        row = []
        row << t
        varnames.keys.each do |shortname|
          vdata = vardata[shortname]
          # Nil values will create ',,'
          row << vdata[t]
        end
        csv << row
      end
    end
  end

  def self.columns_with_metadata(varnames, metadata = {})
    # Return an object of columnized Var data.
    # Metadata may be included in the object.
  
    # Upon entry, we contain the measurements of interest (i.e.
    # they have been time and instrument selected.
    
    # varnames are the names of parameters of interest.
    # Metadata is a hash of metadata than will be prepended to the result.
    
    # Fetch the desired data. A hash is returned. It contains
    # an entry "Time", with data times, and entries for each of the 
    # varnames.
    vardata = MeasurementsHelper.columnize(self, varnames)
    
    # Convert the nested hashes into vectors
    retval = metadata
    retval["Data"] = {}
    vardata.each do |key, value|
      retval["Data"][key] = value.values
    end
    
    return retval

  end

  # Return a vector containing time(ms) and value
  def mstime_and_value
    time = Time.new(self.measured_at.year, self.measured_at.month, self.measured_at.day, self.measured_at.hour, self.measured_at.min, self.measured_at.sec, "+00:00")
    milliseconds = ((time.to_i) * 1000).to_s
    return [milliseconds.to_i, self.value]
  end
  
  def age
    time_ago_in_words(self.measured_at)
  end
  
end


