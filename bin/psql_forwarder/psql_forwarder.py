#!/usr/local/bin/python

# Install psycopg2:
#  pip install psycopg2
#  pip install pycurl

import psycopg2
import pycurl
import json
import argparse

#####################################################################
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
        parser.add_argument("-v", "--verbose",     help="verbose output", action="store_true")

        args = parser.parse_args()
        self.options = vars(args)
        
        if not args.config:
            parser.print_help()
            exit(1)

    def get_options(self):
        return self.options 

#####################################################################
class Config:
    def __init__(self, path):
        self.lines = []
        self.json = ""
        configfile = open(path, "r")
        for l in configfile:
            if len(l) > 0:
                if l[0] != "#":
                    self.lines.append(l.strip())
                    self.json += l.strip()
        self.config = json.loads(self.json)
        
    def get_config(self):
        return self.config

#####################################################################
class ADS_db:
    def __init__(self, dbhost, dbname, dbuser, dbtable):
        self.dbname  = dbname
        self.dbuser  = dbuser
        self.dbhost  = dbhost
        self.dbtable = dbtable
    
        conn = psycopg2.connect(host=self.dbhost, database=self.dbname, user=self.dbuser)
        self.cursor = conn.cursor()
    
    def list_columns(self):
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
        # cols is an array containing column names
        sql = "select "
        i = 0
        for c in cols:
            if i > 0:
                sql = sql + ','
            sql = sql + c
            i += 1
        sql = sql + " from " + self.dbtable + ";"
        self.cursor.execute(sql)

    def next_row(self):
        row = self.cursor.fetchone()
        return row

#####################################################################
class Measurement:
    def __init__(self, short_name, value):
        self.short_name = short_name
        self.value_str = str(value)    
    
#####################################################################
def make_CHORDS_url(host, id, measurements=[], key=None, time=None):
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
    return url

#####################################################################
def option_override(name, options, config):
    retval = None
    if name in config:
        retval = config[name]
    if name in options:
        retval = options[name]
    return retval

#####################################################################

options = CommandArgs().get_options()
print options

c = Config(options['config']).get_config()
print c
            
chords_host = option_override('chords_host', options, c)
key         = option_override('key', options, c)
db_name     = option_override('db_name', options, c)
db_host     = option_override('db_host', options, c)
db_user     = option_override('db_user', options, c)
db_table    = option_override('db_table', options, c)

instrument_id = c['instrument_id']
time_col      = c['time_column']
column_dict   = c['var_short_names']

db = ADS_db(dbhost=db_host, dbname=db_name, dbtable=db_table, dbuser=db_user)

columns = []
for col,short_name in column_dict.iteritems():
    columns.append(col)

missing_cols = db.verify_columns(columns)
if (len(missing_cols) > 0):
    print "Columns",
    for c in missing_cols:
        print c + ",",
    print "do not exist in database:" + db.dbname + ", table:" + db.dbtable
    exit(1)

db.get_values(columns)

for c, s in column_dict.iteritems():
    print c+":"+s,
print

for r in range(10):
    row = db.next_row()
    measurements = []
    time = None
    for c, v in zip(columns, row):
        if c != 'datetime':
            short_name = column_dict[c]
            m = Measurement(short_name, v)
            measurements.append(m)
        else:
            time = str(v).replace(" ","T")
    url = make_CHORDS_url(host=chords_host, id=instrument_id, measurements=measurements, time=time, key=key)
    print url
