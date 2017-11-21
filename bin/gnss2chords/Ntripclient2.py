#!/usr/bin/python -u
"""
This is heavily based on the NtripPerlClient program written by BKG.
"""

import socket
import sys
import datetime
import base64
import time
from optparse import OptionParser


version=0.1 
useragent="NTRIP UnavcoPythonClient/%.1f" % version

# reconnect parameter (fixed values):
reconnectstarttime=10.0
factor=0.02
ramptime1=500.0
ramptime2=20000.0
reconnectendtime=400.0
maxReconnect=10000


class Unbuffered:
    """
    Python buffers by default.  You can 
    run python with the -u switch to avoid this, but that's
    a bit onerous.  Instead, we'll wrap stdout with this.
    See: http://stackoverflow.com/questions/107705/python-output-buffering
    """
    def __init__(self, stream):
        self.stream = stream
    def write(self, data):
        self.stream.write(data)
        self.stream.flush()
    def __getattr__(self, attr):
        return getattr(self.stream, attr)


class NtripClient(object):
    def __init__(self, 
                 buffer=50, 
                 user="", 
                 out=Unbuffered(sys.stdout), 
                 port=2101, 
                 caster="",
                 mountpoint="",
                 lat=46,
                 lon=122,
                 directConnect=False):
        self.buffer=buffer
        self.user=base64.b64encode(user)
        self.out=out
        self.port=port
        self.caster=caster
        self.mountpoint=mountpoint
        self.setPosition(lat, lon)
        self.directConnect=directConnect
        
        self.socket=None
        

    def setPosition(self, lat, lon):
        self.flagN="N"
        self.flagE="E"
        if lon>180:
            lon=(lon-360)*-1
            self.flagE="W"
        elif (lon<0 and lon>= -180):
            lon=lon*-1
            self.flagE="W"
        elif lon<-180:
            lon=lon+360
            self.flagE="E"
        else:
            self.lon=lon
        if lat<0:
            lat=lat*-1
            self.flagN="S"
        self.lonDeg=int(lon)
        self.latDeg=int(lat)
        self.lonMin=(lon-self.lonDeg)*60
        self.latMin=(lat-self.latDeg)*60

    def getMountPointString(self):
        mountPointString = "GET /%s HTTP/1.0\r\nUser-Agent: %s\r\nAuthorization: Basic %s\r\n\r\n" % (self.mountpoint, useragent, self.user)
        print mountPointString
        return mountPointString
    
    def getGGAString(self):
        now = datetime.datetime.utcnow()
        ggaString= "GPGGA,%02d%02d%04.2f,%02d%011.8f,%1s,%03d%011.8f,%1s,1,05,0.19,+00400,M,47.950,M,," % \
            (now.hour,now.minute,now.second,self.latDeg,self.latMin,self.flagN,self.lonDeg,self.lonMin,self.flagE)
	#print  ggaString 
        checksum = self.calcultateCheckSum(ggaString)
        return "$%s*%s\r\n" % (ggaString, checksum)
        
    def calcultateCheckSum(self, stringToCheck):
        xsum_calc = 0
        for char in stringToCheck:
            xsum_calc = xsum_calc ^ ord(char)
        return "%02X" % xsum_calc
        
    def readData(self):
        reconnectTry=0
        sleepTime=0
        reconnectTime=0
        try:
            while reconnectTry<maxReconnect:
                self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                error_indicator = self.socket.connect_ex((self.caster, self.port))
		print self.caster, self.port

                if error_indicator==0:
                    if not self.directConnect:
                        self.socket.sendall(self.getMountPointString())
                        casterResponse=self.socket.recv(1024)
                        print casterResponse.strip()
                        if casterResponse.find("SOURCETABLE")>=0:
                            print "Mount point does not exist"
                            print "Writing sourcetable.dat"
                            f = open("sourcetable.dat", "w")
                            data=""
                            #while self.socket:
                            while not data.find("ENDSOURCETABLE")>=0:
                                data = self.socket.recv(50)
                                f.write(data)
                            f.close()
                            self.socket.close()
                            self.socket=None
                            sys.exit(1)
                        elif casterResponse.find("401 Unauthorized")>=0:
                            print "Unauthorized request"
                            sys.exit(1)
                        elif casterResponse.find("ICY 200 OK")>=0:
                            #Request was valid
                            self.socket.sendall(self.getGGAString())
                    data = "Initial data"
                    while data:
                        data=self.socket.recv(self.buffer)
                        self.out.write(data)
                    self.socket.close()
                    self.socket=None
                else:
                    reconnectTry += 1
                    sleepTime += reconnectTime
                    if sleepTime<=ramptime1:
                        reconnectTime=reconnectstarttime
                    if sleepTime>ramptime2:
                        reconnectTime=reconnectendtime
                    if (sleepTime>ramptime1) and (sleepTime<=ramptime2):
                        reconnectTime=factor*sleepTime
                    self.socket=None
                    print "%s No Connection to NtripCaster.  Trying again in %f seconds" % (datetime.datetime.now(), sleepTime)
                    time.sleep()
        except KeyboardInterrupt:
            if self.socket:
                self.socket.close()
            sys.exit()

if __name__ == '__main__':
    usage="NtripPythonClient.py [options] caster port mountpoint"
    parser=OptionParser(version=version, usage=usage)
    parser.add_option("-u", "--user", type="string", dest="user", default="anonymous", help="The Ntripcaster username.  Default: %default")
    parser.add_option("-b", "--buffer-size", type="int", dest="buffer", default=50, help="The buffer size, in bytes.  This determines how often data are written to out.  Default: %default")
    parser.add_option("-a", "--latitude", type="float", dest="lat", default=50.09, help="Your latitude.  Default: %default")
    parser.add_option("-o", "--longitude", type="float", dest="lon", default=8.66, help="Your longitude.  Default: %default")
    parser.add_option("-d", "--direct-connect", action="store_true", dest="directConnect", default=False, help="Connect directly to a streaming device; don't use ntrip at all")
    parser.add_option("-f", "--outputFile", type="string", dest="outputFile", default=None, help="Write to this file, instead of stdout")
    (options, args) = parser.parse_args()
    if len(args) != 3 and options.directConnect!=True:
        print "Incorrect number of arguments\n"
        parser.print_help()
        sys.exit(1)
    ntripArgs = {}
    ntripArgs['caster']=args[0]
    ntripArgs['port']=int(args[1])
    if len(args)==3:
        ntripArgs['mountpoint']=args[2]
    ntripArgs['buffer']=options.buffer
    ntripArgs['lat']=options.lat
    ntripArgs['lon']=options.lon
    ntripArgs['user']="xxx:xxx"
    ntripArgs['directConnect']=options.directConnect
    fileOutput=False
    if options.outputFile:
        f = open(options.outputFile, 'w')
        ntripArgs['out']=f
        fileOutput=True
    n = NtripClient(**ntripArgs)
    try:
        n.readData()
    finally:
        if fileOutput:
            f.close()
