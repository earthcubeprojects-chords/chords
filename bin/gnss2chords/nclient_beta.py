#!/Users/joshj55/anaconda/bin/python2.7

"""
A python client for connecting to a Ntrip server

This is heavily based on the NtripPerlClient program written by BKG.

You can set the Ntrip username and password by specifying the -u argument to NtripClient.py
or by setting the environment variable NTRIP_USER.  In both cases, the format is
username:password

This requires Python 2.7
"""

import socket
import sys
import datetime
import base64
import time
from argparse import ArgumentParser
import logging
import os

__version__ = 0.2

logger = logging.getLogger(__name__)
module_name = file_name = __file__.split("/")[len(__file__.split("/"))-1]

useragent = 'NTRIP UnavcoPythonClient/%.1f' % __version__

# reconnect parameter (fixed values):
RECONNECT_START_TIME = 10.0
FACTOR = 0.05
RAMPTIME_1 = 60.0
RECONNECT_ENDTIME = 600.0
MAX_SLEEP_TIME = 600.0
MAX_RECONNECT = 100

DEFAULT_USER = 'anonymous'


class MountPointException(Exception):
    pass


class NtripClient(object):
    def __init__(self,
                 buffer_size=128,
                 user=DEFAULT_USER,
                 out=sys.stdout,
                 port=2101,
                 caster='rtgpsout.unavco.org',
                 mountpoint='P501',
                 lat=50.09,
                 lon=8.66,
                 direct_connect=False,
                 never_give_up=False,
                 timeout=60):
        self.buffer_size = buffer_size
        self.user = base64.b64encode(user)
        self.out = out
        self.port = port
        self.caster = caster
        self.mountpoint = mountpoint
        self.latitude = lat
        self.longitude = lon
        self.direct_connect = direct_connect
        self.never_give_up = never_give_up
        socket.setdefaulttimeout(timeout)
        self.socket = None
        self._sleep_time = 0
        self.reconnect_attempts = 0

    def _get_position(self):
        """
        Calculate the position as used in the GGA String
        :return:
        """
        flagN = 'N'
        flagE = 'E'
        lon = self.longitude
        lat = self.latitude
        if lon > 180:
            lon = (lon - 360) * -1
            flagE = 'W'
        elif 0 > lon >= -180:
            lon = lon * -1
            flagE = 'W'
        elif lon < -180:
            lon = lon + 360
            flagE = 'E'
        if lat < 0:
            lat = lat * -1
            flagN = 'S'
        lonDeg = int(lon)
        latDeg = int(lat)
        lonMin = (lon - lonDeg) * 60
        latMin = (lat - latDeg) * 60
        return latDeg, latMin, flagN, lonDeg, lonMin, flagE

    @property
    def sleep_time(self):
        """
        Calculate the amount of time for which we should sleep

        The sleep time should slowly increase over time until we hit MAX_SLEEP_TIME
        """
        if self._sleep_time <= RAMPTIME_1:
            self._sleep_time += RECONNECT_START_TIME
        elif self._sleep_time > RAMPTIME_1:
            self._sleep_time += FACTOR * self._sleep_time
        if self._sleep_time >= MAX_SLEEP_TIME:
            self._sleep_time = MAX_SLEEP_TIME
        return self._sleep_time

    @sleep_time.setter
    def sleep_time(self, value):
        self._sleep_time = value

    def _reset_sleep_time(self):
        self.sleep_time = 0
        self.reconnect_attempts = 0

    def get_mount_point_string(self):
        """
        Calculate the mountpoint string to send to the caster
        """
        mountPointString = 'GET /%s HTTP/1.0\r\nUser-Agent: %s\r\nAuthorization: Basic %s\r\n\r\n' % \
                           (self.mountpoint, useragent, self.user)
        return mountPointString

    def get_gga_string(self):
        """
        Calculate the GGA string to send to the Ntrip Caster
        """
        now = datetime.datetime.utcnow()
        latDeg, latMin, flagN, lonDeg, lonMin, flagE = self._get_position()
        ggaString = 'GPGGA,%02d%02d%04.2f,%02d%011.8f,%1s,%03d%011.8f,%1s,1,05,0.19,+00400,M,47.950,M,,' % \
                    (now.hour, now.minute, now.second, latDeg, latMin, flagN, lonDeg, lonMin,
                     flagE)
        checksum = self.calculate_check_sum(ggaString)
        return '$%s*%s\r\n' % (ggaString, checksum)

    @staticmethod
    def calculate_check_sum(stringToCheck):
        """
        Calculate the checksum of a string
        """
        xsum_calc = 0
        for char in stringToCheck:
            xsum_calc = xsum_calc ^ ord(char)
        return '%02X' % xsum_calc

    def negotiate_with_caster(self):
        """
        Negotiate with the caster, after connection
        """
        # Don't bother negotiating with the caster
        if self.direct_connect is True:
            logger.debug('Connecting directly to a stream')
            return
        self.socket.sendall(self.get_mount_point_string())
        caster_response = self.socket.recv(1024)
        if caster_response.find('SOURCETABLE') >= 0:
            logger.error('Mount point does not exist')
            logger.debug('Sourcetable:\n')
            data = caster_response
            # while self.socket:
            while not data.find('ENDSOURCETABLE') >= 0:
                data += self.socket.recv(self.buffer_size)
            logger.debug(data)
            self._close_socket()
            raise MountPointException
        elif caster_response.find('401 Unauthorized') >= 0:
            logger.error('Unauthorized request')
            # Exit code 2 for authorization failure.
            sys.exit(2)
        elif caster_response.find('ICY 200 OK') >= 0:
            logger.info('Connected successfully...')
            self.socket.sendall(self.get_gga_string())

    def _close_socket(self):
        """
        Attempt to close the socket
        :return: None
        """
        try:
            if self.socket is not None:
                self.socket.close()
        except socket.error as f:
            logger.debug('Failed to close socket properly: %s', f)
        finally:
            self.socket = None

    def read_data(self):
        try:
            while self.reconnect_attempts < MAX_RECONNECT or self.never_give_up is True:
                self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                try:
                    self.socket.connect((self.caster, self.port))
                except socket.error:
                    logger.exception('Failed to connect to caster...')
                    self._close_socket()
                else:
                    try:
                        logger.info('Negotiating with caster...')
                        self.negotiate_with_caster()
                    except socket.error:
                        logger.exception('Failed to negotiate with caster...')
                        self._close_socket()
                    except MountPointException:
                        pass
                    else:
                        # Connected successfully, reset the connection attempts
                        self._reset_sleep_time()
                        data = 'Initialize'
                        logger.info('Receiving data...')
                        while data:
                            try:
                                data = self.socket.recv(self.buffer_size)
                                self.out.write(data)
                                # Flush immediately so we don't buffer
                                self.out.flush()
                            except socket.error:
                                logger.exception('Connection to receiver failed')
                                break
                self.reconnect_attempts += 1
                self._close_socket()
                sleepTime = self.sleep_time
                logger.info('Trying again in %.1f seconds\n' % sleepTime)
                time.sleep(sleepTime)
        except KeyboardInterrupt:
            if self.socket:
                self.socket.close()
            sys.exit()


if __name__ == '__main__':
    user_environment_var = 'NTRIP_USER'

    parser = ArgumentParser(description='A simple client to connect to a Ntrip caster')
    parser.add_argument('-u', '--user', type=str, dest='user', default=DEFAULT_USER,
                        help='''The Ntripcaster username.  If you have a password, use the format username:password.  
For better security, set the environment variable %s, so the user name will not show up on the command line.  If both
are set, I will use the username specified on the command line. 
Default: %%(default)s''' % user_environment_var)
    parser.add_argument('-b', '--buffer-size', type=int, dest='buffer', default=128,
                        help='The buffer size, in bytes.  This determines how often data are written.  Default: %(default)s')
    parser.add_argument('-a', '--latitude', type=float, dest='lat', default=50.09,
                        help='Your latitude.  Default: %(default)f')
    parser.add_argument('-o', '--longitude', type=float, dest='lon', default=8.66,
                        help='Your longitude.  Default: %(default)f')
    parser.add_argument('-d', '--direct-connect', action='store_true', dest='directConnect', default=False,
                        help='Connect directly to a streaming device; do not use ntrip at all')
    parser.add_argument('-f', '--outputFile', type=str, dest='outputFile', default=None,
                        help='Append to this file, instead of writing to stdout')
    parser.add_argument('-n', '--never-give-up', action='store_true', dest='neverGiveUp',
                        help='Never quit retrying.  By default, I will retry %d times' % MAX_RECONNECT)
    parser.add_argument('-t', '--timeout', type=int, default=60,
                        help='Timeout, in seconds, for connection to caster.  Default: %(default)s')
    parser.add_argument('caster', type=str, help='The address of the caster')
    parser.add_argument('port', type=int, help='The port of the caster')
    parser.add_argument('mountpoint', type=str, help='The name of the mountpoint', nargs='?')
    args = parser.parse_args()
    ntrip_args = dict(
        caster=args.caster,
        port=args.port,
        buffer_size=args.buffer,
        lat=args.lat,
        lon=args.lon,
        user=args.user,
        direct_connect=args.directConnect,
        never_give_up=args.neverGiveUp,
        timeout=args.timeout
    )
    if args.mountpoint is not None:
        ntrip_args['mountpoint'] = args.mountpoint
    fileOutput = False
    if args.outputFile is not None:
        f = open(args.outputFile, 'ab')
        ntrip_args['out'] = f
        fileOutput = True

    if ntrip_args['user'] == DEFAULT_USER:
        ntrip_args['user'] = os.environ.get(user_environment_var, DEFAULT_USER)

    n = NtripClient(**ntrip_args)

    logging.basicConfig(level=logging.INFO, stream=sys.stderr,
                        format='%(asctime)s (' + module_name + ') %(levelname)s: %(message)s')

    try:
        n.read_data()
    finally:
        if fileOutput:
            f.close()
