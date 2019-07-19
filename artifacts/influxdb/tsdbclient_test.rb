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
  our_opts[:host]        = "influxdb"
    
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: " + program_name + " [options]"

    opts.on("-d", "--database db", "Database name") do |a|
      our_opts[:database] = a
    end

    opts.on("-o", "--host host",   "Host name") do |a|
      our_opts[:host] = a
    end
    
    opts.on("-p", "--ping",       "Ping influxdb on host") do |a|
      our_opts[:ping] = true
    end

    opts.on("-v", "--version",   "Print debugging information") do |a|
      our_opts[:version] = true
    end

    opts.on("-h", "--help",          "Prints this help") do
      puts opts
      exit
    end
  end
  
  # Parse the arguments
  opt_parser.parse!(options)
  
  # Do some error checking
  
  if error == true
    puts opt_parser
    exit
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

  if options.key?(:ping) then
  begin
    TSDBClient::ping(options[:host], 1)
    print "ping succeeded\n"
  rescue InfluxDB::Error => e
    print "Unable to ping database at #{options[:host]}: ", e, "\n"
  end
end

if options.key?(:version) then
  begin
    version = TSDBClient.version(options[:host], 1)
    print "version ", version, "\n"
  rescue InfluxDB::Error => e
    print "Unable to get database version at #{options[:host]}: ", e, "\n"
   end
end

TSDBClient_options = {host: options[:host], retry: 1}
if options.key?(:database) then
  TSDBClient_options.merge({database: options[:database]})
end

begin
  db = TSDBClient.new(options[:database], TSDBClient_options)
rescue InfluxDB::Error => e
  print "Unble to connect to database at #{options[:host]}: ", e, "\n"
end
