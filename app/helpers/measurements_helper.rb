module MeasurementsHelper
include ActionView::Helpers::DateHelper

  def self.columnize(m, varnames)
  
    # Upon entry, m contains the measurements of interest (i.e.
    # they have been time and instrument selected. varnames
    # contains the var shortnames that we want to extract.
    #
    # We will return a hash. There will be a hash entry identified as "Time",
    # containg a vector of the data times. Additional hash entries will be
    # keyed by the shortname, and will contain a vector of data values. If
    # data is not avialable at a given time, the value will be nil.
    
    # Create a vector of unique times
    times = m.pluck(:measured_at).uniq.sort
    
    vardata = {}
    # Create the time hash entry.
    vardata["Time"] = {}
    times.each do |t|
      vardata["Time"][t] = t
    end
    
    # Extract the Var data value for each varshortname.
    # Each entry in vardata will be a hash, where the keys will be the
    # timestamp, and the value will be the measurement value.
    varnames.keys.each do |shortname|
      vararrays = m.where("parameter = ?", shortname).pluck(:measured_at, :value)
      vardata[shortname] = {}
      vararrays.each do |v|
        vardata[shortname][v[0]] = v[1]
      end
    end
    return vardata
  end


end
