## Introduction

This is the README file with information and instructions for the suite of scripts used to access UNAVCO Real-Time Data streams and upload parsed data to the online cybertool CHORDS. You can find additional CHORDS documentation in this repository or from the main [CHORDS documentation](https://earthcubeprojects-chords.github.io/chords-docs/)

Creators: 1. Josh Jones, 1. D. Sarah Stamps, 2. Charles Martin  
Institutions: 1. Virginia Tech, Blacksburg, VA. 2. UCAR, Boulder, CO.  
Date last modified: 18 Dec 2020

The following are the scripts provided and required for the package GNSS2CHORDS.
These scripts require Python2.7 to run.
Before first run change run path at beginning of each file to current Python2.7 path.

## chords_stream.py
Main code that initializes the GNSS2CHORDS package. 
* Starts the UNAVCO data stream according to parameters in `parameter.json`.
* Pushes the process to the background as a subprocess.
* Writes data to a temporary file `chords_temp.txt`.

## chords_parse.py
* Does not need to be run, is called by `chords_stream.py`. 
* Reads data from `chords_temp.txt`.
* Parses the data and converts to proper units.
* Builds the necessary url for CHORDS upload and sends the data to the CHORDS portal.

## nclient_beta.py
* UNAVCO Ntripclient that is used to connect and stream UNAVCO's real-time data.

## Parameter file
* `parameter_file.json`
* File specifying connection options
* Username and Password must be added.
* CHORDS information must be added:
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

1. Check what Python2.7 instance you are using and change the `#!ENTER/PATH/HERE` in Line 1 for each file appropriately. 
This directory needs to be current enough to run the python module `psutil`.
* If you do not have the python module `psutil` it can be downloaded through `pip` or your equivilent method.

2. Make sure that all scripts and files are in the same directory.

3. Edit the parameter file to input your UNAVCO username and password.
* If you do not have one, please reach out to UNAVCO real-time data services and request one.
* Information on the process and contact information is available at [UNAVCO Real-Time Services](https://www.unavco.org/data/gps-gnss/real-time/real-time.html) web page.

4. Edit the parameter file to add the sites you want data from and the CHORDS portal ID's.

5. Run either `./chords_stream.py` or to run in the background `./chords_stream.py &&`.
* Standard output will print connection status and potential errors 
* For no messages, run `./chords_stream.py > dev/null &&`.
* This script will call the others in the correct order.

6. A file called `chords_temp.txt` will be generated after starting, but it will be empty.

7. Check your CHORDS portal to see if the stream is successful.
* This script, if not run from the background, will have to be stopped to run another command in the same terminal window. 

