#
# You may need to:
#  pip install pycurl

import json
import argparse
import pycurl
import os
import fnmatch
import time
from StringIO import StringIO

#####################################################################
"""
Manage the command line options.
The options are collated in a dictionary keyed on the option long name.
The option dictionary will only contain the options that are present on the command line.
"""
class CommandArgs:
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
#####################################################################
"""
Manage the configuration of paws_to_chords

The configuration is defined in a json file, which is converted directly to
a python object. The syntax of the configuration file is given in the 
sample config.json file. This class will validate the configuration,
as expected in that definition.
"""
class Config:
    """
    Parameters
      path - path to the configuration file
    """
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
        
        # Make sure that the configuration is well formed
        if not self.validate_config():
            exit(1)
        
    """
    Validate the confguration.
    
    This occurs after the file text has been turned into the self.config
    object. Make sure that required keys exist in the object, which will be
    a nested dictionary. 
    
    Return -  True if ok, False if otherwise.
    """
    def validate_config(self):
        # return true if config is valid, false otherwise.
        retval = True
        required = ['chords_host', 'instrument_id', 'top_dir', 'cycle_secs', 'sensors']
        for r in required:
            if r not in self.config:
                print 'parameter "' + r + '" is not present in the configuration'
                retval = False
        if not retval:
            return retval
        
        sensors = self.config['sensors']
        required = ['short_names', 'sub_dir', 'file_pattern']
        for s in sensors:
            for r in required:
                if r not in s:
                    print 'parameter "' + r + '" for sensor "' + s + '" is not present in the configuration'
                    retval = False
            
        return retval
        
    
    """
    Return the configuration dictionary.
    """
    def get_config(self):
        return self.config
    
    """
    return the json string version of the configuration.
    """
    def json_str(self):
        return self.json

#####################################################################
#####################################################################
"""
Represent a measurement, with short name, timestamp and value.
"""
class Measurement:
    def __init__(self, short_name, timestamp, value):
        self.short_name = short_name
        self.timestamp  = timestamp
        self.value      = value   
    
    """
    Provide printable version of Measurement instances.
    """
    def __repr__(self):
        return self.short_name + ',' + self.timestamp + ',' + self.value
            
#####################################################################
#####################################################################
"""
Access the files that provide variables for one sensor.

SensorFile will search a directory for the last modified
file, and to parse the last line of the file. 

The data lines in a file are formatted with whitespace separated values as follows:
month day year hour minute var1 ... varN 

Enhancement: keep track of modification time, and only read the file if it has changed
since the last time we looked at it.
"""
class SensorFile:
    """
    Constructor.
    Parameters:
      dir - The directory to scan for files.
      pattern - The file glob pattern. Note that this is shell type
        globbing, which is different regular expresion matching.
    """
    def __init__(self, dir, pattern):
        self.dir = dir
        self.pattern = pattern
        if not os.access(self.dir, os.R_OK):
            print 'Directory ' + self.dir + ' is not readable'
            exit(1)

    """
    Return the most recently modified file that matches the glob pattern.
    The returned file is the complete path.
    If there are no matched files, None is returned
    """
    def current_file(self):
        filter = self.pattern
        files = os.listdir(self.dir)
        files = fnmatch.filter(files, filter)
        fullfiles = []
        for f in files:
            fullfiles.append(os.path.join(self.dir, f))
        files = sorted(fullfiles, key=os.path.getmtime)
        if len(files) > 0:
            return files[len(files)-1]
        return None
    
    """
    Find the last line of the most recent file.
    
    Returns:
      None - if there is no file, or an empty file
      Otherwise - The last line

    This first implementation is very inefficient: it reads the 
    whole file just to find the last line. Not an issue if the file
    is not too large, and not read too often. But if this program is 
    inspecting large files or frequently checking them, there are
    several threads on stackoverflow which discuss more efficient 
    methods.
    """
    def last_line(self):
        filepath = self.current_file()
        if not filepath:
            return None
        f = open(filepath, 'r')
        lines = f.readlines()
        if len(lines) == 0:
            return None
        lastline = lines[len(lines)-1].strip()
        return lastline
    
    """
    Return the tupple:(time, [values])
    time will be in ISO8061 format
    If there are not enough tokens to create a time string,
    the return value will be (None, None)
    """
    def time_and_values(self):
        line = self.last_line()
        if not line:
            return (None, None)            
        tokens = line.split()
        if len(tokens) < 6:
            return (None, None)
        timestamp = tokens[2]+'-'+tokens[0]+'-'+tokens[1]+'T'+tokens[3]+':'+tokens[4]
        values = tokens[5:]
        return (timestamp, values)
   
#####################################################################
#####################################################################
"""
Represent one sensor, which is associated with one file.
There can multiple variables for a single sensor. This
class will "scan" the sensors for the most recent variable
values, and return them as a consolidated list of Measurements.
Note that the measurements will not necessarily all have the
same timestamp.
"""
class Sensor:
    """
    Parameters
      short_names - A list of variable shortnames to be paired with
        columns in the data file. The columns following the datestamp will
        be considered. If the shortname is "*", the column will be skipped.
      dir - The directroy which will be searched for data files
      file_pattern - The file matching pattern, which uses shell globbing syntax.
    """
    def __init__(self, short_names, dir, file_pattern):
        self.short_names = short_names
        self.sensor_file = SensorFile(dir, file_pattern)
        
    """
    Returns - the most recent data file for the sensor.
    """
    def current_file(self):
        return self.sensor_file.current_file()
    
    """
    Returns - The measurements for this sensor. There may be no
    measurements avaiable, if a file is not avaiable.
    """
    def measurements(self):
        # Get the current timetamp and the associated values
        (timestamp, values) = self.sensor_file.time_and_values()
        
        measurements = []
        if not timestamp:
            return measurements
        
        # Match the variable short_names to the values,
        # creating the Measurements
        for i in range(len(self.short_names)):
            # We may have fewer values than shortnames.
            if i < len(values):
                if self.short_names[i] != '*':
                    m = Measurement(self.short_names[i], timestamp, values[i])
                    measurements.append(m)
            
        return measurements
    
#####################################################################
#####################################################################
"""
Represent an instrument, which contains Sensors. 

On demand, collect all of the current measurements for all 
sensors.
"""
class Instrument:
    def __init__(self, id, top_dir, sensors):
        self.id = id
        self.sensors = []
        for s in sensors:
            dir = os.path.join(top_dir, s['sub_dir'])
            sensor = Sensor(s['short_names'], dir, s['file_pattern'])
            self.sensors.append(sensor)
            
    """
    A utility function, mainly useful for debugging.
    
    Returns - a list of the currently relevant files for all sensors.
    """
    def files(self):
        f = []
        for s in self.sensors:
            f.append(s.current_file())

        return f

    """
    Returns - a list of last Measurements for all sensors.
    """
    def measurements(self):
        measurements = []
        for s in self.sensors:
            measurements = measurements + s.measurements()
        return measurements

#####################################################################
#####################################################################
'''
Create CHORDS URLs from measurements.

One URL will be created for each unique time across the 
collection of measurements.

Parameters:
  instrument_id: string.
  measurements: an array of Measurement. Note that they can hae differing timestamps.
  key (optional): the security key (text).
  test (optional): set True to generate the test qualifier.
'''
def make_CHORDS_urls(host, id, measurements=[], key=None, test=None):

    # Find the unique times in these measurements
    timestamps = [m.timestamp for m in measurements]
    timestamps = set(timestamps)
    
    # Build URLs for each unique timestamp
    urls = []
    for timestamp in timestamps:
        # Get all measurements at this time
        measurements_at_time = [m for m in measurements if m.timestamp == timestamp]

        # Build the URL
        url = "http://" + host + "/measurements/url_create?instrument_id="+str(id)
        for m in measurements_at_time:
            url += "&" + m.short_name + "=" + m.value
        url += "&at=" + timestamp 
        if key:
            url += "&key=" + key 
        if test:
            url += "&test"
        
        # Save the new url   
        urls.append(url)
        
    return urls

#####################################################################
"""
Send the URL

Parameters
  url - the full url
 """
def http_GET(url):
    
    # Note: pycurl is very sensitive to unicode/string issues
    
    c = pycurl.Curl()
    c.setopt(c.URL, str(url))

    buffer = StringIO()
    c.setopt(c.WRITEFUNCTION, buffer.write)
    
    c.perform()
    
    # HTTP response code, e.g. 200.
    # getinfo must be called before close.
    status = c.getinfo(c.RESPONSE_CODE)   
    c.close()
    
    return status

#####################################################################
def make_and_send_url(instrument):

     # fetch measurements from the files.
    measurements = instrument.measurements()

    # Make a url
    urls = make_CHORDS_urls(
        host=config['chords_host'], 
        id=config['instrument_id'], 
        measurements=measurements, 
        key=key,
        test=test)
    
    # Send the url
    for url in urls:
        status = http_GET(url)
        if verbose:
            print url
            print status

#####################################################################

# Get the command line options
options = CommandArgs().get_options()
if options['verbose']:
    print "Command line options:"
    print options

verbose    = options['verbose']
key        = options['key']
test       = options['test']

# Parse the configuration file
config_file  = Config(options['config'])

# Convert the configuration to a dictionary
config        = config_file.get_config()

# Show the json configuration
if verbose:
    print 'JSON configuration:'
    print config_file.json_str()

# Create an instrument, based on a list of sensors.
# The sensors know which files to scan.
instrument = Instrument(config['instrument_id'], 
                        config['top_dir'], 
                        config['sensors'])

# Repeat
while True:
    make_and_send_url(instrument)
    time.sleep(float(config['cycle_secs']))

