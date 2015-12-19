#!/usr/bin/python

"""
psql_forwarder is used to relay time series observations from a postgress database to
a CHORDS Portal (http://chordsrt.com)

It connects to the database, and then LISTENS for NOTIFY events. Upon reception
of the event, it reads the last row from the selected table, extracts those values,
creates a URL, and transmits it to the CHORDS Portal.

A configuration file specifies the data columns, database specifictions, CHORDS
variables, etc. Security sensitive configuration detains can be specified on the
command line, so that they are not published to your revision control system.

Psycopg2 is used for postgress access. Pycurl provides URL handling. You may need to:
  pip install psycopg2
  pip install pycurl

The following is a copy of a psql_forwarder configuration file. The configuration is
provided in json.
#
# Note: Comment lines must begin with a leading hash charcter. These comment lines must be striped 
# from this file before attempting to parse it as pure JSON. psql_forwarder does this internally.
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
#    time_at:         If true, the value from the db time_column will be submitted with the ?at= parameter.
#  O test:            If true, the "&test" query parameter will be atteed to the CHORDS url.
#  O verbose:         If true, enable verbose reporting.
#  * condition_name:  The Postgres NOTIFY condition name.
#  * instrument_id:   The CHORDS instrument id.
#  * time_column:     The name of the database table column containing the row timestamp.
#  * var_short_names": A hash of mappings between db columns and CHORDS variable short names.
#
# Generally you will have all of the fields specified in the configuration file, in which case
# the command line would look like:
# ./psql_forwarder.py -f g5.json -k ABCDEF
{
  "chords_host":     "xxx.xxx.xxx",
  "db_host":         "xxx.xxx.xxx",
  "db_name":         "xxxxxxx",
  "db_user":         "xxx",
  "db_table":        "xxxx",
  "time_at":         true,
  "test":            false,
  "verbose":         false,
  "condition_name":  "current",
  "instrument_id":   "100",
  "time_column":     "datetime",
  "var_short_names": {
     "cnts":   "cnts",
     "pcn":    "pcn",
     "bdifr":  "bdifr",
     "adifr":  "adifr"
   }
}
"""

import psycopg2
import pycurl
import json
import argparse
import select
import pycurl
from StringIO import StringIO

#####################################################################
"""
Manage the command line arguments

The options are collated in a dictionary keyed on the option long name.
The option dictionary will only contain the options that are present on the command line.
"""
class CommandArgs:
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

        # Parse the options and put them in the
        args = parser.parse_args()
        self.options = vars(args)
        
        # Check for required options.
        if not args.config:
            parser.print_help()
            exit(1)

    def get_options(self):
        # return the dictionary of existing options.
        return self.options 

#####################################################################
"""
Configuration management. 

The JSON configuration file is read and converted to a python object.
"""
class Config:
    """
    Extract configuration key value pairs from a json configuration file.
    """
    def __init__(self, path):
        self.lines = []
        self.json = ""
        configfile = open(path, "r")
        # read the configuration file, removing the commented lines.
        # save the text in elf.json
        for l in configfile:
            if len(l) > 0:
                if l[0] != "#":
                    self.lines.append(l)
                    self.json += l
        # self.config contains the decoded structure.
        self.config = json.loads(self.json)
        
    """
    Returns: the configuration structure.
    """
    def get_config(self):
        return self.config
    
    """
    Returns: The configuration source JSON text.
    """
    def json_str(self):
        # Return the json that was parsed.
        return self.json

#####################################################################
"""
Abstraction for an ADS database. Although it probably could represent
any postgres database.

The last row of a designated table in the database will be the
a source of variable values.

One column will be designated as the time source.

"""
class ADS_db:
    """
    Connect to the database.
    
    Parameters
      dbhost      - The postgres db host.
      dbname      - The postgres db name. 
      dbuser      - The postgres db user.
      dbtable     - The postgres db table source for variables. 
      sort_column - The column to sort on when retrieving the last row
    """
    def __init__(self, dbhost, dbname, dbuser, dbtable, sort_column):
        self.dbname      = dbname
        self.dbuser      = dbuser
        self.dbhost      = dbhost
        self.dbtable     = dbtable
        self.sort_column = sort_column
    
        self.conn = psycopg2.connect(host=self.dbhost, database=self.dbname, user=self.dbuser)
        # This seems to be recommended when using listen
        self.conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        # get a cursor
        self.cursor = self.conn.cursor()
    
    """
    Return the columns in self.dbtable
    """
    def get_columns(self):
        # Return a list of column names,
        self.cursor.execute("select column_name from information_schema.columns where table_name = '" + self.dbtable +"';")
        return self.cursor.fetchall()
    
    """
    """
    def verify_columns(self, columns):
        # Return a list of missing column names
        retval = []
        x = self.get_columns()
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
        sql = sql + " from "+self.dbtable+" order by "+self.sort_column+" desc limit 1;"
        self.cursor.execute(sql)

    def next_row(self):
        # Get the next row at the cursor.
        # Returns: a list of values.
        row = self.cursor.fetchone()
        return row

    def listen(self, condition_name):
        # Enable the listen
        sql = "LISTEN " + condition_name + ";"
        self.cursor.execute(sql)
    
    """
    Return True if one or more notifications were received
    Return False if the select timed out
    """
    def wait_for_notify(self, timeout, verbose=False):
        # Wait for action on the socket
        if select.select([self.conn],[],[],timeout) == ([],[],[]):
            # Select timed out
            return False
        else:
            # select returned
            self.conn.poll()
            while self.conn.notifies:
                notify = self.conn.notifies.pop(0)
            return True

#####################################################################
"""
"""
class Measurement:
    # Represent a CHORDS measurement.
    def __init__(self, short_name, value):
        self.short_name = short_name
        self.value_str = str(value)    
    
    def __repr__(self):
        return '(' + self.short_name + ',' + self.value_str + ')'

#####################################################################
"""
"""
def make_CHORDS_url(host, id, measurements=[], key=None, time=None, test=None):
    # Create a CHORDS URL.
    # instrument_id: string
    # measurements: an array of Measurement
    # key (optional): the security key (text)
    # time (optional): ISO time string
    url = "http://" + host + "/measurements/url_create?instrument_id="+str(instrument_id)
    for m in measurements:
        # Do not try to add lists
        if m.value_str[0] != '[':
            # Don't add missing values
            if m.value_str != "-32767.0":
                url += "&" + m.short_name + "=" + m.value_str
    if key:
        url += "&key=" + key 
    if time:
        url += "&at=" + time 
    if test:
        url += "&test"
    return url

#####################################################################
"""
"""
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
"""
"""
def http_GET(url):
    # Send the URL
    
    buffer = StringIO()
    c = pycurl.Curl()
    c.setopt(c.URL, str(url))
    c.setopt(c.WRITEFUNCTION, buffer.write)
    c.perform()
    
    # HTTP response code, e.g. 200.
    status = c.getinfo(c.RESPONSE_CODE)   
    # getinfo must be called before close.
    c.close()
    
    return status

#####################################################################
"""
"""
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
"""
Interogate the database for a row of values.
Return these as a list of measurements

Parameters
  db - the database
  vars - a dictionary of column_name:short_name

Return: (time, Measurement[])
"""
def get_measurements(db, vars):
    
    # Create a list of column names from the list of variables
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
#####################################################################

# Main

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

# The postgres notify condition name
condition_name= config['condition_name']
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
db = ADS_db(dbhost=db_host, dbname=db_name, dbtable=db_table, dbuser=db_user, sort_column=time_col)
if verbose:
    print 'Database columns:'
    cols = db.get_columns()
    for c in cols:
        print "   ", c[0]

# Make sure that the columns exist in the database. The program will
# exit if they don't exist
verify_columns(db, vars)

# Set up a listen
db.listen("current")

while 1:
    # Wait for a notification
    if db.wait_for_notify(5, verbose):
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
        
