#!/usr/bin/env ruby


require 'optparse'
require 'socket'
require 'net/http'
require 'json'
  
############################################################
# Parse the arguments. 
# Return {:chordshost, [:instrument_id, :udp_port, :template, :variables]}
def parse(program_name, options)
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

# get the options
options = parse($0, ARGV)

puts options


