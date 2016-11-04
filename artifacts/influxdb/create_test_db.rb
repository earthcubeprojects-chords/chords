#!/usr/bin/env ruby

require_relative 'TSDBClient'
require 'json'
require 'time'
require 'optparse'

############################################################
# Parse the command line arguments

def parse_options(program_name, options)
  error = false
  our_opts = {}
  our_opts[:verbose]     = false
  our_opts[:host]        = "influxdb"
  our_opts[:sites]       = 10
  our_opts[:instruments] = 10
  our_opts[:snames]      = 7
    
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: " + program_name + " [options]"

    opts.on("-d", "--database db",   "Database name") do |a|
      our_opts[:database] = a
    end

    opts.on("-o", "--host host",     "Host name") do |a|
      our_opts[:host] = a
    end

    opts.on("-t", "--table table",   "Table (series) name") do |a|
      our_opts[:table] = a
    end

    opts.on("-s", "--sites n",       "Number of sites") do |a|
      our_opts[:sites] = a.to_i
    end

    opts.on("-i", "--instruments n", "Number of instruments") do |a|
      our_opts[:instruments] = a.to_i
    end

    opts.on("-n", "--snames n",      "Number of variable shortnames") do |a|
      our_opts[:snames] = a.to_i
    end

    opts.on("-v", "--verbose",       "Print debugging information") do |a|
      our_opts[:verbose] = true
    end

    opts.on("-h", "--help",          "Prints this help") do
      puts opts
      exit
    end
  end
  
  # Parse the arguments
  opt_parser.parse!(options)
  
  # Do some error checking
  if our_opts[:database].nil?
    error = true
    puts "A database must be specified"
  end  

  if our_opts[:table].nil?
    error = true
    puts "A table must be specified"
  end  
  
  if error == true
    puts opt_parser
    exit
  end
  
  # Print the command line options
  if our_opts[:verbose]
    puts "Program options:"
    puts our_opts
    puts
  end
 
  if error == true
    exit
  end
  
  # If the options pass muster, return the results
  return our_opts
  
end

############################################################

# get the options and configuration
options = parse_options($0, ARGV)

table        = options[:table]
nsites       = options[:sites]
ninstruments = options[:instruments]
nsnames      = options[:snames]

began_at   = Time.now
next_time  = began_at
t_delta    = 0.05

sites       = (1..nsites).map      { |i| "#{i}" }
instruments = (1..ninstruments).map{ |i| "#{i}" }
snames      = (1..nsnames).map     { |i| "#{i}" }

db_options = {database: options[:database], host: options[:host], time_precision: 'ms'}
db = TSDBClient.new(db_options)

# Start at the earlies existing value
q = "select first(\"value\") from \"#{table}\""
result = db.query(q)
if result.length > 0 then
  begin_at = Time.parse(result[0]["values"][0]["time"])
end

count = 0
loop do
  sites.each do |site|
    instruments.each do |inst|
      data = []
      snames.each do |sname|
        # Random data
        value = rand
        # Bump data time
        ts = next_time.to_i*1000 + (next_time.usec/1000).to_i
        # Create data record
        data <<  
          {
          series: table,
          tags: {
            site:       site,
            instrument: inst,
            sname:      sname
          },
          values: { value: value},
          timestamp: ts
        }
      end
      #puts JSON.pretty_generate(data)
      # Write to DB
      db.write_points(data)
      
      # Bump time
      next_time = next_time-t_delta;
      
      # Status print
      if (count % 1000 == 0) then
        print count, " elapsed: ", Time.now - began_at, "s  Current timestamp: ", next_time.to_s, "\n"
      end
      count = count + snames.length
    end
  end
end
  