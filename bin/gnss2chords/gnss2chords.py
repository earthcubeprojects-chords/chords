#!/usr/bin/python -u
"""
Transfer data from the GNSS server to a CHORDS server.

Ntripclient2.py is used to connect and download data from a caster server.
The returned data are parsed, and a url is created and sent the the CHORDS server.

Ntripclient2.py runs as a process which just streams records for the selected
caster ID. This scripts reads continuously from that stream.

Thus, this script will run continuously until it is externally killed.

In order to make it play well with crontab, the script checks to see if
it is already running with the same arguments. If so, it just exits.

"""

import sys
import time
import commands
import os
import subprocess
import requests

base_name = os.path.basename(sys.argv[0])

##################################################################
def usage():
	"""
	Print the usage text.
	"""
	
	print "Usage: " + base_name + \
	  " [-t] casterUser:casterPw casterServer casterPort casterId chordsName chordsInstrument"
	print
	print "For example:"
	print "   /home/user/gnss2chords.py martin:12345678 rtgpsout 2110 OLO3 tzvolcano 2"
	print "   The caster server will become casterServer.unavco.org."
	print "   The CHORDS server will become chordsName.chordsrt.com."
	print
	print "Include the -t option before the arguments, to operate in test mode."
	print "In test mode, GNSS data and CHORDS URL are printed, but no data is sent to CHORDS."
	print
	print base_name, "will check to see if another instance is running with the same arguments,"
	print "and will exit if this is true."

##################################################################
def check_args(opts):
	"""
	Decode the options and arguments.
	
	Return a dictionary containing the option/arguments.
	Note that options (i.e. those with a dash) are removed from
	sys.argv.
	"""

	opts["test_mode"] = False
	
	# We require 6 or 7 arguments
	if len(sys.argv) < 7 or len(sys.argv) > 8:
		usage();
		exit (1);

	# See if there are opts
	if len(sys.argv) == 8:
		if sys.argv[1] == "-t":
			opts["test_mode"] = True
			# Remove the option argument
			del sys.argv[1]
		else:
			usage()
			exit(1)

	# Note: the option parameter has been removed from sys.arg. 
	# Save the the other parameters
	opts["caster_user"]   = sys.argv[1].split(":")[0]
	opts["caster_pw"]     = sys.argv[1].split(":")[1]
	opts["caster_ip"]     = sys.argv[2] + ".unavco.org"
	opts["caster_port"]   = sys.argv[3]
	opts["caster_id"]     = sys.argv[4] + "_RTX"
	opts["chords_ip"]     = sys.argv[5] + ".chordsrt.com"
	opts["chords_inst"]   = sys.argv[6]
	
	return opts
	
	
##################################################################
def currently_running():
	"""
	See if there is another instance of this script running, using the 
	same arguments.
	
	The ps command is used to find other instances.
	
	return True if running with same arguments.
	"""

	# Get my process id
	my_pid  = os.getpid()
	my_args = sys.argv[1:]
	my_name = base_name
	
	# search for all instances of this script.
	ps_cmd = "ps -eo pid,cmd | grep '%s' | grep -v grep" % my_name
	status,result = commands.getstatusoutput(ps_cmd)
	processes_w_my_name = result.split("\n")
	count = 0
	for r in processes_w_my_name:
		r = r.strip().split(" ")
		pid = r[0]
		if int(pid) == my_pid:
			# Ignore this instance
			pass
		else:
			args = r[4:]
			if args == my_args:
				# Found another identical instance.
				count = count + 1	
	if count > 0:
		return True
		
	return False

##################################################################
def ntrip_start(opts):
	"""
	Start the the ntrip client process.
	"""
    
	print "(Re)starting Ntripclient2"
	
	# Ntripclient2.py --user $1 $2.unavco.org $3 $4_RTX
	proc_cmd = ['/usr/bin/python', '-u', './Ntripclient2.py', 
	  "--user", opts["caster_user"] + ":" + opts["caster_pw"], 
	  opts["caster_ip"], 
	  opts["caster_port"], 
	  opts["caster_id"]]
	proc = subprocess.Popen(proc_cmd,stdout=subprocess.PIPE)
	return proc

##################################################################
def validate(data):
	""" 
	Validate the data fields returned by the ntrip client. 
	- Each token is examined to see if it has the correct length.
	- Height should have EHT at the beginning.
	"""
    
    # We are expecting:
	# date     time       lat       latns       lon       lonew     height
	#093017 181043.00 0245.23896775   S    03552.28365983   E     EHT1483.140
	
	err = False
	for name, l in (("date",6), ("time",9), ("lat",13), ("latns",1), ("lonew",1), ("lon",14)):
		err = err or (len(data[name]) != l)
	
	err = err or (len(data["height"]) < 4) or (data["height"][0:3] != "EHT")
	
	data["valid"] = not err	
		
##################################################################
def ntrip_data(proc):
	""" 
	Get the next $PTNL record from the ntrip client.
	Skip any empty records, sleeping for a second when
	one is received.
	
	Return a dictionary of alphanumeric values:
	  data["time" ]:  time
	  data["date"] :  date
	  data["lat"]  :  latitude
	  data["latns"]:  N/S hemisphere
	  data["lon"]  :  longitude
	  data["lonew"]:  E/W hemisphere
	  data["height"]: height
	  data["valid"] : (boolean) will be true if validation check passed.
	"""
	
	data = {}
	data["time" ]= ""
	data["date"] = ""
	data["lat"]  = ""
	data["latns"]= ""
	data["lon"]  = ""
	data["lonew"]= ""
	data["line"] = ""
	data["valid"]= False

	
	# ntripclient output will look like:
	# rtgpsout.unavco.org 2110
	# GET /OLO3_RTX HTTP/1.0
	# User-Agent: NTRIP UnavcoPythonClient/0.1
	# Authorization: Basic ZHN0YW1wczpUajRKWDcxTw==
	# 
	# 
	# ICY 200 OK
	# $PTNL,GGKx,175330.00,093017,0245.23897327,S,03552.28365810,E,14,10,1.7,EHT1483.106,M,3,0.014,0.017,0.051*07
	# $PTNL,GGKx,175331.00,093017,0245.23897193,S,03552.28365366,E,14,10,1.7,EHT1483.113,M,3,0.013,0.016,0.051*03
	# $PTNL,GGKx,175332.00,093017,0245.23897301,S,03552.28365649,E,14,10,1.7,EHT1483.104,M,3,0.014,0.017,0.051*01

	while True:
		line = proc.stdout.readline()
		line = line.strip()
		#print time.strftime("%d/%m/%Y %H:%M:%S"), line
		data["line"] = line
		if len(line) > 0:
			tokens = line.split(",")
			if len(tokens) == 17:
				if tokens[0] == "$PTNL":
					data["valid"]  = True
					data["time"]   = tokens[2]
					data["date"]   = tokens[3]
					data["lat"]    = tokens[4]
					data["latns"]  = tokens[5]
					data["lon"]    = tokens[6]
					data["lonew"]  = tokens[7]
					data["height"] = tokens[11]
					# date     time       lat       latns       lon       lonew     height
					#093017 181043.00 0245.23896775   S    03552.28365983   E     EHT1483.140
					validate(data)
			break
		else:
			# Empty line; try again in one second
			time.sleep(1)

	return data

##################################################################
def chords_create(opts, data):
	"""
	Create a CHORDS url and send it to the CHORDS server.
	"""
	
	date  = data["date"]
	time  = data["time"]
	lat   = data["lat"]
	latns = data["latns"]
	lon   = data["lon"]
	lonew = data["lonew"]
	height= data["height"][3:]
	valid = data["valid"]
	
	# date     time       lat       latns       lon       lonew     height
	#093017 181043.00 0245.23896775   S    03552.28365983   E     EHT1483.140
	latf = float(lat[0:2])+float(lat[2:])/60.0
	# The current gnss2chords.sh is not correcting for S latitude.
	# Uncomment these lines to enable the adjustment.
#	if latns == 'S':
#		latf = -latf
	lonf = float(lon[0:3])+float(lon[3:])/60.0
	if lonew == 'W':
		lonf = -lonf
		
	# http://tzvolcano.chordsrt.com/measurements/url_create?instrument_id=2&lat=2.7539827755&lon=35.8713943987&height=1483.113&at=2017-09-30T20:17:28.00
	timestamp = "20" + date[4:6] + "-" + date[0:2] + "-" + date[2:4] + \
	   "T" + time[0:2] + ":" + time[2:4] + ":"  + time[4:]
	url = "http://" + opts["chords_ip"] + "/measurements/url_create?" + \
	      "instrument_id=" + opts["chords_inst"] + \
	      "&lat=" + str(latf) + \
	      "&lon=" + str(lonf) + \
	      "&height=" + height + \
	      "&at=" + timestamp

	if opts["test_mode"]:
		print data["line"]
		print url
	else:
		try:
			response = requests.get(url=url)
		except requests.exceptions.RequestException as e:
			print "Error contacting " + opts["chords_ip"] + ":", e

##################################################################
##################################################################
if __name__ == '__main__':

	opts = {}
	check_args(opts)
	
	# See if we are already runnnng in this configuration
	if currently_running():
		print base_name,
		for a in sys.argv[1:]:
			print a,
		print ": I am already running with the same arguments, exiting."
		exit(1)

	print time.strftime("%d/%m/%Y %H:%M:%S"), 'Starting', base_name
	
	if opts["test_mode"]:
		print "Operating in test mode. Data will not be sent to CHORDS."

	# Run the ntrip client
	proc = ntrip_start(opts)
	
	# Loop over lines received from the ntrip client. Note that this loop
	# does not exit, unless the ntrip client has an unrecoverable error.
	while True:
		if proc.poll() is not None:
			# Restart ntpclient proc if it has exited
			time.sleep(1)
			proc = ntrip_start(opts)
		else:		
			data= ntrip_data(proc)
			if not data["valid"]:
				print "Error in ntrip data:", data["line"]
				time.sleep(0.05)
			else:
				chords_create(opts, data)

