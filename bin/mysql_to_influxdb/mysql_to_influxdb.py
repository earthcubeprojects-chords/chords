#! /usr/local/bin/python

import argparse
from subprocess import call
from datetime import datetime

#
# Extract time-series data for a specified date range from a MySQL server
# running in the docker container "chords_mysql". 
#
# The extracted time series are written in the InfluxDB line format.
#

timestamp = datetime.now()

#####################################################################
def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--prefix",  required=True,  help="output file name prefix (required)")
    parser.add_argument("-s", "--start",   required=True,  help="start time (MySQL format), e.g. 2017, 2017-02, 2017-02-15 12, 2017-02-15 12-15 (required)")
    parser.add_argument("-e", "--end",     required=True,  help="end time   (MySQL format), e.g. 2017, 2017-02, 2017-02-15 12, 2017-02-15 12-15 (required)")
    parser.add_argument("-v", "--verbose", required=False, help="verbose output (optional)", action="store_true")

    # Parse the command line. 
    myargs = parser.parse_args()
    
    options = vars(myargs)
    # Create nil values for optional arguments that are not present
    if not myargs.verbose:
        options['verbose'] = None
        
    return options
        
#####################################################################
def make_sql(start, end):
    sql = ("SELECT CONCAT("
           "'tsdata,inst=', m.instrument_id, "
           "',site=', instruments.site_id, "
           "',var=', vars.id , "
           "',test=false', "
           "' value=', m.value , "
           "' ', "
           "UNIX_TIMESTAMP(m.measured_at), '000000000') "
           "from measurements as m "
           "left outer join instruments on instruments.id = m.instrument_id "
           "inner join vars ON vars.shortname "
           "LIKE m.parameter AND vars.instrument_id=instruments.id "
           "where m.measured_at >= '" + start + "' "
           "and m.measured_at < '"    + end   + "' "
           ";")
    sql = ("SELECT CONCAT("
           "'tsdata,inst=', m.instrument_id, "
           "',site=', instruments.site_id, "
           "',var=', vars.id , "
           "',test=false', "
           "' value=', m.value , "
           "' ', "
           "UNIX_TIMESTAMP(m.measured_at), '000000000') "
           "from measurements as m "
           "left outer join instruments on instruments.id = m.instrument_id "
           "inner join vars ON vars.shortname "
           "LIKE m.parameter AND vars.instrument_id=instruments.id "
           "where m.measured_at >= '" + start + "' "
           "and m.measured_at < '"    + end   + "' "
           ";")
    return sql

#####################################################################
def make_docker_cmd(sql):
    dc = ["/usr/local/bin/docker", "exec", "-it",  "chords_mysql",  "mysql",  "-N", "-s", "-r",  "chords_demo_production",  "-e",  sql]
    return dc

#####################################################################
def make_file(file_prefix, start, end):
    
    # change blans into dashes
    start_text = start.replace(' ','-')
    end_text = end.replace(' ','-')
    
    influxdb_header = "# DML\n# CONTEXT-DATABASE: chords_ts_production\n\n"
    file_name = file_prefix + "-" + start_text + "-" + end_text + ".txt"
    f = open(file_name, "w")
    f.write(influxdb_header)
    f.flush()
    return f
    
#####################################################################
def time_split():
    global timestamp
    tnow = datetime.now()
    t_split = tnow - timestamp
    timestamp = tnow 
    return t_split

#####################################################################

# Parse arguments.
options = parseArgs()

start       = options["start"]
end         = options["end"]
file_prefix = options["prefix"]

# Create the sql query
sql = make_sql(start, end)

# Build the docker command
dc = make_docker_cmd(sql)

if options["verbose"]:
    print dc

# Create the output file. The influxdb header will be added to it.
f = make_file(file_prefix, start, end)

# Execute the docker command, sending the output to f
call(dc, stdout=f)

f.close()
print start, end, " Elapsed time:", time_split()
