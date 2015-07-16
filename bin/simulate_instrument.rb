#!/usr/bin/env ruby

require 'optparse'
require 'net/http'


############################################################
# Convert a variable specification into {:name, :average, :sigma}
def crack_variable_spec(spec)
  s = spec.split(':')
  result = {}
  if s.count == 3
    result[:name]     = s[0]    
    result[:average]  = s[1].to_f 
    result[:sigma]    = s[2].to_f
  end
  return result
end

############################################################
# Parse the arguments. 
# Return {:chordshost, :instrument_id, :seconds, :variables}
def parse(program_name, options)
  error = false
  our_opts = {}
  our_opts[:seconds] = 1
  our_opts[:variables] = []
    
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: " + program_name + " [options]"

    opts.on("-c", "--chordshost HOST", "Host, e.g. localhost:3000 or chords.dept.univ.edu") do |a|
      our_opts[:chordshost] = a
    end

    opts.on("-i", "--instrument_id ID", "Instrument id") do |a|
      our_opts[:instrument_id] = a
    end

    opts.on("-v", "--variable VARIABLESPEC", "Variable specification id:avg:sigma") do |a|
      spec = crack_variable_spec(a)
      if spec.count == 3
        our_opts[:variables].push(spec)
      else
        error = true
        puts "Invalid variable specification"
      end
    end
  
    opts.on("-s", "--seconds SECONDS", "Repeat interval (s)") do |a|
      our_opts[:seconds] = a
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end
  
  # Parse the arguments
  opt_parser.parse!(options)
  
  # Do some error checking
  if our_opts[:chordshost].nil?
    error = true
    puts "A CHORDS host must be specified"
  end  

  if our_opts[:instrument_id].nil?
    error = true
    puts "Instrument id must be specified"
  end  

  if our_opts[:variables].count == 0
    error = true
    puts "At least one variable must be specified"
  end  

  if error == true
    puts opt_parser
    exit
  end
  
  # If the options pass muster, return the results
  return our_opts
  
end

############################################################

class Variable 
  def initialize(name, avg, sigma)
    @name = name
    @avg  = avg.to_f
    @sigma = sigma.to_f
    @current_value = @avg
  end
  
  def name
    @name
  end
  
  def avg
    @avg
  end
  
  def sigma
    @sigma
  end
  
  def value!
    @current_value = @avg + rand(-1.0..1.0) * @sigma
    return @current_value
  end
  
  # Return the URL segment for this variable, e.g. "tdry=12.4"
  # Prescission is 2 decimal places
  def url_segment!
    name + "=" + "%.2f" % value!
  end

end

############################################################
# Make the complete URL, using all of the variables
# get 'measurements/url_create?instrument_id=:instrument_id&:shortname=value[&:shortname=value]' => 'measurements#url_create'
def make_url(chordshost, instrument_id, variables)
  url = "http://" 
  url += chordshost
  url += "/measurements/url_create?instrument_id="
  url += instrument_id
  variables.each do |v|
    url += "&" + v.url_segment!
  end
  return url
end

############################################################

# get the options
options = parse($0, ARGV)

# create the variables
variables = []
options[:variables].each do |v|
  variables.push(Variable.new(v[:name], v[:average], v[:sigma]))
end

# Loop, sending one request every seconds.
loop do
  url = make_url(options[:chordshost], options[:instrument_id], variables)
  puts url
  uri = URI(url)
  begin
    Net::HTTP.get(uri) 
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  sleep(options[:seconds].to_f)
end
