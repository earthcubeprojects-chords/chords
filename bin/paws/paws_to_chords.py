#!/usr/local/bin/python

# You may need to:
#  pip install pycurl

import json
import argparse
import pycurl
try:
    from io import BytesIO
except ImportError:
    from StringIO import StringIO as BytesIO

#####################################################################
class CommandArgs:
    # Manage the command line options.
    # The options are collated in a dictionary keyed on the option long name.
    # The option dictionary will only contain the options that are present on the command line.
    def __init__(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("-c", "--config",      help="config file (required)")
        parser.add_argument("-k", "--key",         help="security key (optional)")
        parser.add_argument("-t", "--test",        help="add test flag (optional)",  action="store_true")
        parser.add_argument("-v", "--verbose",     help="verbose output (optional)", action="store_true")

        # Parse the command line. 
        args = parser.parse_args()
        self.options = vars(args)
        
        if not args.config:
            parser.print_help()
            exit(1)

        # Create nil values for optional arguments that are not present
        if not args.key:
            self.options['key'] = None
        if not args.test:
            self.options['test'] = None
        if not args.verbose:
            self.options['verbose'] = None
        
    def get_options(self):
        # return the dictionary of existing options.
        return self.options 

#####################################################################
class Config:
    # Extract configuration key value pairs from a json configuration file.
    def __init__(self, path):
        self.lines = []
        self.json = ""
        configfile = open(path, "r")
        for l in configfile:
            if len(l) > 0:
                if l[0] != "#":
                    self.lines.append(l)
                    self.json += l
        self.config = json.loads(self.json)
        
    def get_config(self):
        return self.config
    
    def json_str(self):
        # Return the json that was parsed.
        return self.json

#####################################################################
class Measurement:
    # Represent a CHORDS measurement.
    def __init__(self, short_name, value):
        self.short_name = short_name
        self.value_str = str(value)    
    
#####################################################################
def make_CHORDS_url(host, id, measurements=[], key=None, time=None, test=None):
    # Create a CHORDS URL.
    # instrument_id: string
    # measurements: an array of Measurement
    # key (optional): the security key (text)
    # time (optional): ISO time string
    url = "http://" + host + "/measurements/url_create?instrument_id="+str(instrument_id)
    for m in measurements:
        url += "&" + m.short_name + "=" + m.value_str
    if key:
        url += "&key=" + key 
    if time:
        url += "&at=" + time 
    if test:
        url += "&test"
    return url

#####################################################################
def http_GET(url):
    # Send the URL
    
    buffer = BytesIO()
    c = pycurl.Curl()
    c.setopt(c.URL, 'http://pycurl.sourceforge.net/')
    c.setopt(c.WRITEDATA, buffer)
    c.perform()
    
    # HTTP response code, e.g. 200.
    status = c.getinfo(c.RESPONSE_CODE)   
    # getinfo must be called before close.
    c.close()
    
    return status

#####################################################################

# Get the command line options
options = CommandArgs().get_options()
if options['verbose']:
    print options

verbose = options['verbose']
key     = options['key']
test    = options['test']

# Parse the configuration file
config_file  = Config(options['config'])

# Get the configuration as a dictionary
config        = config_file.get_config()
# Show the json configuration
if verbose:
    print 'JSON configuration:'
    print config_file.json_str()

# Get configuration values
chords_host   = config['chords_host']
instrument_id = config['instrument_id']


measurements = []
time = None

# Make a url
url = make_CHORDS_url(
    host=chords_host, 
    id=instrument_id, 
    measurements=measurements, 
    time=time,
    key=key,
    test=test)

if verbose:
    print url

# Send the url
status = http_GET(url)
if verbose:
    print status

