## Introduction

This is the README file with information and instructions for the suite of scripts used to access UNAVCO Real-Time Data stream and upload parsed data to the online cybertool CHORDS.
Creators: 1. Josh Jones, 1. D. Sarah Stamps, 2. Charles Martin
Institution: 1. Virginia Tech, Blacksburg, Va. 2. UCAR, Boulder, Co.

The following are the scripts provided and required for the package GNSS2CHORDS.
These scripts require Python2.7 to run.
Before first run change run path at beginning of each file to current Python2.7 path.

## chords_stream.py
Main code that initializes the GNSS2CHORDS package. 
* Starts the UNAVCO data stream according to parameters in `parameter.json`.
* Pushes the process to the background as a subprocess.
* Writes data to a file `chords_data.txt`.

## chords_parse.py
* Does not need to be run, is called by `chords_stream.py`. 
* Reads data from `chords_data.txt`.
* Parses the data and converts to proper units.
* Builds the necessary url for CHORDS upload, and sends the data to the CHORDS portal.

## nclient_beta.py
* UNAVCO Ntripclient that is used to connect and stream UNAVCO's real-time data.

## Parameter file
* `parameter_file.json`
* File specifying connection options
* Username and Password must be added.
* Chords information must be added:
	* IP
	* Key
	* Caster Site
	* Instrument ID
* The json file is structured as follows (order is not important):
```
{
  "caster_ip":   "caster IP name",
  "caster_port": "caster port number",
  "caster_user": "caster user name",
  "caster_pw":   "caster password",
  "chords_ip":   "CHORDS portal IP name",
  "chords_key":  "CHORDS portal data ingest key",
  "sites": [
    {"caster_site": "1st caster site", "chords_inst_id": "1st chords instrument id"},
    ...
    {"caster_site": "nth caster site", "chords_inst_id": "nth chords instrument id"}
  ] 
```

# Running the scripts
To run the scripts follow the directions below:

1. Check what Python2.7 directory you are using and change the #!/bin in Line 1 for each file appropriately. 
This directory needs to be current enough to run the module "psutil".
* If you do not have psutil it can be downloaded through pip or your equivilent method.

2. Make sure that all scripts and files are in the same directory.

3. Edit the parameter file to input your UNAVCO username and password.
* If you do not have one, please reach out to UNAVCO real-time data services and request one.

4. Edit the parameter file to add the sites you want data from and the CHORDS portal ID's.

5. Run either `./chords_stream.py` or to run in the background `./chords_stream.py &&`.
* Log will print for connection (for no message add `> dev/null` before the `&&`).
* This script will call the others in the correct order.
* _To avoid potential memory leak issues, run using a cron set to reset once a month._

6. A file called `chords_temp.txt` will be generated after starting, but it will be empty.

7. Check your chords portal to see if the stream is successful.

8. This script, if not run from the background, will have to be stopped to run another command in the same terminal window. 

