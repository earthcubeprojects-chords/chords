#!/usr/bin/env ruby


=begin
# Sample configuration file, which also demonstrates the structure of the final configuration (options[:config])
{
  # Note: These comment lines must be striped from this file before attempting to parse it 
  # as pure JSON. udp_forwarder does this internally.
  
  # Configuration file for the CHORDS udp_forward program.
  #
  # chords_host:   String, the host name or IP of a CHORDS instance. Include port number if necessary.
  # re_terms:      Array of arrays. Each sub-array contains a name and a Rexexp.
  # instruments:   Hash of instrument definitions. Each instrument receieves messages on one port.
  #   enabled:     Boolean, true if the instrument messages will be processed. If false, the port is not used.
  #   port:        Integer, the port to listen for datagrams on.
  #   id:          Integer, the instrument id, as it is known to the CHORDS instance.
  #   sample:      String, an example of a typical message from this instrument.
  #   template:    String, a ruby Regexp with capture fields, for parsing the datagrams into CHORDS variables.
  #   short_names: Array of strings. Each string is paired with on capture field from the template.
  #
  # The re_terms and template fields specify ruby Regexp patterns. 
  #
  # template specifies a ruby RegExp that is used to decode the incoming datagram.
  # The () sections idendify a value that will be paired with the successive :short_name(s).
  #
  # re_terms specify Regexps that can be substituted into the template string,
  # so that the template string doesn't get unwieldy.
  # 
  # Note: If using the backslash character (likely), it must be escaped so that it can pass 
  # through the json parsing.
  
  "chords_host": "chords.dyndns.org",
  
  "re_terms": [ 
    # Match a floating point number
    ["_fp_", "[-+]?[0-9]*\\.?[0-9]+"]
  ],
    
  "instruments": {
   "FL": { 
       "enabled":    true,
       "port":       29110,
       "id":         50,
       "sample":     "1R0,Dm=077D,Sm=1.2M,Sx=2.4M,Ta=29.0C,Ua=27.5P,Pa=838.2H,Rc=317.20M,Vs=18.2V",
       "template":   "1R0,Dm=(_fp_)D,Sm=(_fp_)M,Sx=(_fp_)M,Ta=(_fp_)C,Ua=(_fp_)P,Pa=(_fp_)H,Rc=(_fp_)M,Vs=(_fp_)V",
       "short_names": ["wdir", "wspd", "wmax","tdry","rh","pres","raintot", "batv"]
    }
  }
} 
=end


require 'optparse'
require 'socket'
require 'net/http'
require 'json'
  
############################################################
class MessageProcessor
  @@m = Mutex.new
  
  def initialize(instrument, chords_host, verbose) 
    @@m.lock
    @instrument = instrument
    @chords_host = chords_host
    @verbose = verbose
    @socket = UDPSocket.new
    @socket.bind("127.0.0.1", @instrument.port)
    @thread = Thread.new { self.process }
    @@m.unlock
  end
  
  def process
    if @verbose
      puts "reading port " + @instrument.port.to_s
    end
    
    while 1
      msg, ipaddr = @socket.recvfrom 65536
      url = "http://" + @chords_host
      url += @instrument.url_create(msg)
      if @verbose
        puts url
      end
      http_get(url)
    end
  end
  
  def http_get(url)
    uri = URI(url)
    begin
      Net::HTTP.get(uri) 
    rescue => ex
      puts "#{ex.class}: #{ex.message}"
    end
  end
  
  def join
    @thread.join
  end
  
end

############################################################
class Instrument
  attr_reader :sample
  attr_reader :template
  attr_reader :port
  
  def initialize(name, port, id, template, short_names, sample)
    @name = name
    @template = template
    @short_names = short_names
    @sample = sample
    @id = id
    @port = port
  end
  
  def decode(msg)
    # Use the template to decode the msg into tokens,
    # and then pair them with the short names into a query string
    md = /#{@template}/.match(msg)
    values = {}
    if md
      if md.length != (@short_names.length+1)
        puts 'Incorrect number of variables decoded in message'
        puts '  decoding:' + msg
        puts '  using:' + @template
      else
        i = 1
        @short_names.each do |s|
          values[s] = md[i]
          i += 1
        end
      end
    end
    return values
  end
  
  def url_create(msg)
  
    # Get the variable names and values from the msg
    variables = decode(msg)
   
    # Create the query string
    query = "?instrument_id=" + @id.to_s
    if variables
      variables.each do |key, value|
        query += "&" + key + "=" + value
      end
    end

    # Build the url
    url = "/measurements/url_create"
    url += query
    
    return url
  end
   
  def test
    # return the result of decoding the sample message
    return url_create(@sample)
  end
end

############################################################
def symbolize(obj)
    return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
    return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
    return obj
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
  
  # Ruby 1.8.7 doesn't have the symbolize_names option, so
  # comment it out and use our own method.
  # our_opts[:config] = JSON.parse(config_text, symbolize_names: true)
  our_opts[:config] = symbolize(JSON.parse(config_text))
  
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

# Config contains the configuration structure as defined in the configuration file
config = options[:config]

# Create an array of Instrument, but only for those that have :enabled == true
instruments = []
config[:instruments].each do |key, i|
  if i[:enabled]
    instrument = Instrument.new(key.to_s, i[:port], i[:id], i[:template], i[:short_names], i[:sample])
    instruments << instrument
  end
end

# If verbose, iterate through the instruments, testing the sample string against the template.
if options[:verbose]
  puts "************ Testing message decoding *************"
  instruments.each do |i|
    puts i.test
  end
  puts "***************************************************"
  puts ""
end

# Create an aray of processors. These will start threads listening on instrument ports.
processors  = []
instruments.each do |i|
  processor  = MessageProcessor.new(i, config[:chords_host], options[:verbose])
  processors  << processor
end

processors.each { |p| p.join }

