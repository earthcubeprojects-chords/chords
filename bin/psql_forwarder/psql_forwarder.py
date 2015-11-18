#!/usr/local/bin/python

# Install psycopg2:
#  pip install psycopg2
#  pip install pycurl

import psycopg2
import pycurl

class ADS_db:
    def __init__(self):
        self.dbname = "real-time-C130"
        self.dbuser = "ads"
        self.dbhost = "eol-rt-data.fl-ext.ucar.edu"
        self.dbtable = "raf_lrt"
    
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

class Measurement:
    def __init__(self, short_name, value):
        self.short_name = short_name
        self.value_str = str(value)    
    
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

chords_host = "testbed.chordsrt.com"
instrument_id = 100
key = None
key = "AC341F4"

db = ADS_db()

columns = ['datetime', 'bdifr', 'cnts', 'pcn', 'dpxc']
missing_cols = db.verify_columns(columns)
if (len(missing_cols) > 0):
    print "Columns",
    for c in missing_cols:
        print c + ",",
    print "do not exist in database:" + db.dbname + ", table:" + db.dbtable
    exit(1)

db.get_values(columns)

for c in columns:
    print c,
print

for r in range(10):
    row = db.next_row()
    measurements = []
    time = None
    for c, v in zip(columns, row):
        if c != 'datetime':
            m = Measurement(c, v)
            measurements.append(m)
        else:
            time = str(v).replace(" ","T")
    url = make_CHORDS_url(host=chords_host, id=instrument_id, measurements=measurements, time=time, key=key)
    print url
