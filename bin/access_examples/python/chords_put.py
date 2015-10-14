# Put one data sample into a CHORDS Portal
#
#
import requests

def chords_put(url):
    '''
    Submit an http request to put one measurement to a CHORDS Portal
    '''
    response = requests.get(url=url)
    return response
    
def chords_url(ip, inst_id, data_vars, mtime=None, mkey=None, mtest=None):
    '''
    Build the URL for putting data to CHORDS
    
    ip        - Portal IP (E.g. chords-python.dyndns.org)
    inst_id   - Instrument id (text)
    data_vars - An array of tupples specifying measurements. Each tuple
                contains a shortname and a value. Both are text.
                E.g: [ ['t', 10.1], ['rh', '55.1'], ['ws', '14.1'], ['wd', '214'] ]
    time      - Optional timestamp to apply to measurements, in ISO format
                E.g. '2015-10-14T19:23:31.000Z'
    key       - Optional security key (required if your portal configuration requires it)
    test      - If present, measurement is flagged as a test value.
    '''
    url = 'http://' + ip + '/measurements/url_create?instrument_id=' + inst_id
    for var in data_vars:
        url = url + "&" + var[0] + "=" + var[1]
    if mtime != None:
        url = url + "?at=" + mtime
    if mkey != None:
        url = url + "?key=" + mkey
    if mtest != None:
        url = url + "&test"
    return url

#####################################################################
if __name__ == '__main__':
    # Test
    import sys
    
    if len(sys.argv) != 3:
          print 'usage: ' + sys.argv[0] + ' chords_ip instrument_id'
          print '(include port number for chords_ip if non-standard, e.g. localhost:3000)'
          sys.exit()

    # Get the script parameters                                                                                                              
    script, chords_ip, inst_id = sys.argv
    # Create data variables
    data_vars = [ ['t',  '21.5'], ['rh', '32'], ['ws', '14.2'], ['wd', '321.1'], ['p',  '854.5'], ['b',  '12.1'] ]
    # Security key
    mkey = None
    # Create url
    url = chords_url(ip=chords_ip, inst_id=inst_id, data_vars=data_vars,mkey=mkey,mtest=1)
    print url
    # Send it
    print chords_put(url)
    
    