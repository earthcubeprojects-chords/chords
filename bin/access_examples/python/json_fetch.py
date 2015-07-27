# If your system does not already have the python 'requests' module, install it with 'pip install requests'
#
import sys, json, requests

if len(sys.argv) != 3:
  print 'usage: sys.argv[0] chords_ip instrument_id'
  print '(include port number for chords_ip if non-standard, e.g. localhost:3000)'
  sys.exit()

# Get the script parameters
script, chords_ip, instrument_id = sys.argv

# Create the url
url = 'http://' + chords_ip + '/instruments/' + instrument_id + '.json'

# Fetch the data
response = requests.get(url=url)
data     = json.loads(response.content)

# Print it
print data