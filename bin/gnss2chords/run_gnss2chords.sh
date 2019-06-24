#!/bin/bash

# The home directory where gnss2chords.py and Ntripclient2.py are located.
# Output will also be placed in this directory
srcDir=/home/user/gnss2chords

# Credentials for access to the unavco gnss server
casterUser=user
casterPw=pw

cd $srcDir

./gnss2chords.py $casterUser:$casterPw rtgpsout 2110 OLO1 tzvolcano 1 >> olo1.out 2>&1 & 
./gnss2chords.py $casterUser:$casterPw rtgpsout 2110 OLO3 tzvolcano 2 >> olo3.out 2>&1 & 
./gnss2chords.py $casterUser:$casterPw rtgpsout 2110 OLO6 tzvolcano 5 >> olo6.out 2>&1 & 
./gnss2chords.py $casterUser:$casterPw rtgpsout 2110 OLO7 tzvolcano 6 >> olo7.out 2>&1 & 
./gnss2chords.py $casterUser:$casterPw rtgpsout 2110 OLO8 tzvolcano 7 >> olo8.out 2>&1 & 
./gnss2chords.py $casterUser:$casterPw rtgpsout 2110 OLOT tzvolcano 4 >> oloT.out 2>&1 & 
