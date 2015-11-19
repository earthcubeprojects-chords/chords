#!/usr/local/bin/python

# You may need to:
#  pip install psycopg2
#  pip install pycurl

#
# psql_forwarder configuration file, in JSON format.
#
# Note: Comment lines must begin with a leading hash charcter. These comment lines must be striped 
# from this file before attempting to parse it 
# as pure JSON. psql_forwarder does this internally.
#
# Configuration file for the CHORDS psql_forward program.
# Those marked with a * are required in the configuration file. 
# Others may be specified either here or on the command line of the program.
# Those marked "O" are completely optional, and do not have to be specified
# at all unless the option is needed.
#
#    chords_host:     The CHORDS Portal IP.
#    db_host:         The ADS database IP.
#    db_name:         The ADS database name.
#    db_user:         The ADS database user.
#    db_table:        The ADS database table.
#  O test:            If true, the "&test" query parameter will be atteed to the CHORDS url.
#  O verbose:         If true, enable verbose reporting.
#  * instrument_id:   The CHORDS instrument id.
#  * time_column:     The name of the database table column containing the row timestamp.
#  * var_short_names": A hash of mappings between db columns and CHORDS variable short names.
#
#{
#  "chords_host":     "xxx.xxx.xxx",
#  "db_host":         "xxx.xxx.xxx",
#  "db_name":         "xxxxxxx",
#  "db_user":         "xxx",
#  "db_table":        "xxxx",
#  "time_at":         true,
#  "test ":           false,
#  "verbose"          false,
#  "instrument_id":   "100",
#  "time_column":     "datetime",
#  "var_short_names": {
#     "cnts":   "cnts",
#     "pcn":    "pcn",
#     "bdifr":  "bdifr",
#     "adifr":  "adifr"
#   }
# }


import psycopg2
import pycurl
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
        parser.add_argument("-f", "--config",      help="config file (required)")
        parser.add_argument("-d", "--db_host",     help="database host")
        parser.add_argument("-n", "--db_name",     help="database name")
        parser.add_argument("-u", "--db_user",     help="database user")
        parser.add_argument("-t", "--db_table",    help="database table")
        parser.add_argument("-c", "--chords_host", help="chords host")
        parser.add_argument("-k", "--key",         help="key")
        parser.add_argument("-s", "--test",        help="add test flag", action="store_true")
        parser.add_argument("-v", "--verbose",     help="verbose output", action="store_true")

        args = parser.parse_args()
        self.options = vars(args)
        
        if not args.config:
            parser.print_help()
            exit(1)

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
class ADS_db:
    # Manage the database connection.
    # All future transactions will be made against dbtable.
    def __init__(self, dbhost, dbname, dbuser, dbtable):
        self.dbname  = dbname
        self.dbuser  = dbuser
        self.dbhost  = dbhost
        self.dbtable = dbtable
    
        conn = psycopg2.connect(host=self.dbhost, database=self.dbname, user=self.dbuser)
        self.cursor = conn.cursor()
    
    def list_columns(self):
        # Return a list of olumn names,
        self.cursor.execute("select column_name from information_schema.columns where table_name = '" + self.dbtable +"';")
        return self.cursor.fetchall()
    
    def verify_columns(self, columns):
        # Return a list of missing column names
        retval = []
        x = self.list_columns()
        db_cols = []
        for y in x:
            db_cols.append(y[0])
        for c in columns:
            if c not in db_cols:
                retval.append(c)
        return retval

    def get_values(self, cols):
        # Execute a query for the specified columns. The 
        # cursor will be set to the result.
        # cols: a list containing column names
        # return: Nothing
        sql = "select "
        i = 0
        for c in cols:
            if i > 0:
                sql = sql + ','
            sql = sql + c
            i += 1
        sql = sql + " from " + self.dbtable + " limit 1;"
        self.cursor.execute(sql)

    def next_row(self):
        # Get the next row at the cursor.
        # Returns: a list of values.
        row = self.cursor.fetchone()
        return row

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
def option_override(name, options, config):
    # Determine the final value of the configuration option.
    # If the named item exists in options, that  will be returned. 
    # Otherwise, if it exists in config, that will be returned.
    # Else None will be returned.
    # name: the option name
    # options: a dictionary of option values.
    # config: a dictionary of configuration values.
    retval = None
    if name in config:
        retval = config[name]
    if name in options:
        if options[name] != None:
          retval = options[name]
    return retval

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
def verify_columns(db, vars):
    # Verify that the specified columns exist in the database
    # db: the database
    # vars: a dictionary of column_name:short_name

    # Extract the column names
    columns = []
    for col,short_name in vars.iteritems():
        columns.append(col)
    
    missing_cols = db.verify_columns(columns)
    if (len(missing_cols) > 0):
        print "Columns",
        for c in missing_cols:
            print c + ",",
        print "do not exist in database:" + db.dbname + ", table:" + db.dbtable
        exit(1)

#####################################################################
def get_measurements(db, vars):
    # Interogate the database for a row of values.
    # Return these as a list of measurements
    # db: the database
    # vars: a dictionary of column_name:short_name
    # Return: time, Measurement[]
    
    # Extract the column names
    columns = []
    for col,short_name in vars.iteritems():
        columns.append(col)
    
    # Get a row for these columns
    db.get_values(columns)
    row = db.next_row()
    
    # Process the row
    measurements = []
    time = None
    for c, v in zip(columns, row):
        if c != time_col:
            short_name = vars[c]
            m = Measurement(short_name, v)
            measurements.append(m)
        else:
            time = str(v).replace(" ","T")
            
    return time, measurements
    
#####################################################################
# Get a row from the database, convert it to a URL, and send to a
# CORDS Portal

# Get the command line options
options = CommandArgs().get_options()

# Load the configuration file
config_file  = Config(options['config'])
config = config_file.get_config()

# Set values from configuration and options. Options override the configuration.
# If the value was not specified in either place, it is set to None
chords_host = option_override('chords_host', options, config)
db_name     = option_override('db_name',     options, config)
db_host     = option_override('db_host',     options, config)
db_user     = option_override('db_user',     options, config)
db_table    = option_override('db_table',    options, config)
key         = option_override('key',         options, config)
test        = option_override('test',        options, config)
verbose     = option_override('verbose',     options, config)

# These options must be in the configuration file
instrument_id = config['instrument_id']

# The name of the column used for the timestamp
time_col      = config['time_column']

# config['var_short_names'] will be a dictionary of column_names:short_name entries.
vars          = config['var_short_names']

# Show the json configuration
if verbose:
    print 'JSON configuration:'
    print config_file.json_str()

if verbose:
    print "Requested columns and shortnames:"
    for k,v in vars.iteritems():
        print "   ", k + ":", v
        
# Open the database
db = ADS_db(dbhost=db_host, dbname=db_name, dbtable=db_table, dbuser=db_user)
if verbose:
    print 'Database columns:'
    cols = db.list_columns()
    for c in cols:
        print "   ", c[0]

# Make sure that the columns exist in the database. The program will
# exit if they don't exist
verify_columns(db, vars)

# Get a set of measurements from the database
time, measurements = get_measurements(db, vars)

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

