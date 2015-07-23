#!/usr/bin/env ruby


=begin
# Sample configuration file, which also demonstrates the structure of the final configuration (options[:config])
{
  # Note: These comment lines must be striped from this file before attempting to parse it as pure JSON.
  
  # Configuration file for the CHORDS udp_forward program.
  # The :re_terms and :template fields contain Ruby RegExp patterns. 
  #
  # :template specifies a ruby RegExp that is used to decode the incoming datagram.
  # The () sections idendify a value that will be paired with the successive :short_name(s).
  #
  # :re_terms specify strings that can be substituted into the :template string,
  # so that the template strings don't get unwieldy.
  # 
  # If using the backslash character (likely), it must be escaped so that it can pass 
  # through the json parsing.
  
  # The host that HTTP GET will be sent to.
  "chords_host": "chords.dyndns.org",
  
  # These terms will replace tokens of the same name in the template.
  "re_terms": [ 
    # Match a floating point number
    ["_fp_", "[-+]?[0-9]*\\.?[0-9]+"]
  ],
    
  # An array of instruments that will be received and forwarded. 
  "instruments": {
   "FL": { 
       "enabled":    true,
       "port":       29110,
       "sample":     "1R0,Dm=077D,Sm=1.2M,Sx=2.4M,Ta=29.0C,Ua=27.5P,Pa=838.2H,Rc=317.20M,Vs=18.2V",
       "template":   "1R0,Dm=(_fp_)D,Sm=(_fp_)M,Sx=(_fp_)M,Ta=(_fp_)C,Ua=(_fp_)P,Pa=(_fp_)H,Rc=(_fp_)M,Vs=(_fp_)V",
       "short_names": ["wdir", "wspd", "wmax","tdry","rh","pres","raintot", "batt"]
    },
    
   "ML": { 
       "enabled":    false,
       "port":       29111,
       "sample":     "1R0,Dm=358D,Sm=3.1M,Sx=7.0M,Ta=26.5C,Ua=27.0P,Pa=813.5H,Rc=453.20M,Vs=13.9V",
       "template":   "1R0,Dm=([0-9]*.[0-9]*)D,Sm=([0-9.]*)M,Sx=([0-9.]*)M",
       "short_names": ["wdir", "wspd", "wmax","tdry","rh","pres","raintot", "batt"]
    },
    
   "NWSC": { 
       "enabled":    false,
       "port": 29113,
       "sample":     "1r0,Dm=001D,Sm=5.0M,Sx=6.8M,Ta=21.6C,Ua=42.3P,Pa=806.3H,Rc=420.80M,Vs=12.4VMXu",
       "template":   "100,Dm=([0-9]*.[0-9]*)D,Sm=([0-9.]*)M,Sx=([0-9.]*)M",
       "short_names": ["wdir", "wspd", "wmax","tdry","rh","pres","raintot", "batt"]
    }
  }
}
=end


require 'optparse'
require 'socket'
require 'net/http'
require 'json'
  
############################################################
############################################################
class Instrument
  def initialize(name, template, short_names)
    @name = name
    @template = template
    @short_names = short_names
  end
  
  def decode(msg)
    # Use the template to decode the msg into tokens,
    # and then pair them with the short names
  end
end
############################################################
# Parse the command line arguments, and process the configuration file. 
# Return {:config_file, :verbose, :config}
# See the sample configuration (above) for the description of :config
def options_and_configure(program_name, options)
  error = false
  our_opts = {}
  our_opts[:verbose] = false
    
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: " + program_name + " [options]"

    opts.on("-c", "--config CONFIGFILE", "Configuration file (JSON)") do |a|
      our_opts[:config_file] = a
    end

    opts.on("-v", "--verbose", "Print debugging information") do |a|
      our_opts[:verbose] = a
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end
  
  # Parse the arguments
  opt_parser.parse!(options)
  
  # Do some error checking
  if our_opts[:config_file].nil?
    error = true
    puts "A configuration must be specified"
  end  

  if error == true
    puts opt_parser
    exit
  end
  
  # Read the configuration file, strip out the comments, and parse as json
  config_text = ''
  File.readlines(our_opts[:config_file]).each do |line|
    line = line.gsub(/#.*/,'').strip
    if line.length > 0
      config_text << line
    end
  end
  
  our_opts[:config] = JSON.parse(config_text, symbolize_names: true)
  
  if our_opts[:verbose]
    puts "Input configuration:"
    puts our_opts[:config]
    puts
  end
  
  instruments = our_opts[:config][:instruments]
  if instruments
    # Process the configuration for each instrument
    instruments.each do |key, i|
      if !i[:template]
        puts "A template is required for instrument #{key.to_s}"
        error = true
      else
        if ![:short_names]
          puts "Short names are required for instrument #{key.to_s}"
          error = true
        else 
          # Perform the :re_terms substitutions
          if our_opts[:config][:re_terms]
            our_opts[:config][:re_terms].each do |r|
              term = r[0]
              newvalue = r[1]
               i[:template] = i[:template].gsub(/#{term}/, newvalue)
            end
          end
        end
      end
    end
  else
    puts "At least one instrument must be defined in the configuration"
    error = true
  end
  
  if error == true
    exit
  end
  
  if our_opts[:verbose]
    puts "Configuration after :re_terms substitutions:"
    puts our_opts[:config]
    puts
  end
  
  # If the options pass muster, return the results
  return our_opts
  
end
############################################################

# get the options and configuration
options = options_and_configure($0, ARGV)

config = options[:config]

instruments = {}
config[:instruments].each do |key, i|
  if i[:enabled]
    instruments[i[:port]] = Instrument.new(key.to_s, i[:template], i[:short_names])
  end
end

puts instruments
