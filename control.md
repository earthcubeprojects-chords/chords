# CHORDS Setup and Control

CHORDS configuration and control are performed by running a python management script from the
directory containing the configuration files.

_Note: On systems where docker requires root, you may need to use sudo to run these commands._

#### Requirements:
 * python 2.7 (Linux and MacOS have this by default; [install](https://www.python.org/downloads/windows/) on Windows)
 * curl (Linux and MacOS have this by default; [install](https://help.zendesk.com/hc/en-us/articles/229136847-Installing-and-using-cURL#install) on Windows)
 * A running docker system
 * Port 25 must be open. Port 3000 must be open for the Grafana visualization, but you can use CHORDs without this 
   feature.

#### Installation:
````
# Select the configuration directory
cd <configuration directory>

# Fetch the CHORDS management script
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control

# Create configuration files (_chords.yml_ and _.env_ will be created)
# (Be prepared to enter an admin password of your choosing.)
python chords_control --config

# Update the CHORDS software
python chords_control --update
````

#### Running:
````
python chords_control --run
````

#### Verifying:
* Point your browser at the CHORDS portal by entering the IP address of the system into the address bar. This may be
_localhost_ if CHORDS is on the same machine as you browser. On W7 machines, get the IP from the output of: 
````docker-machine ip````
* It can take quite a while for the initial page load to finish, as the server initializes its caches. A
Raspberry Pi can take up to a couple of minutes. 
* Sign in with admin@chordsrt.com (realtimedata). Immediately change this admin account password (under Users). You will
  probably also want to uncheck "Restrict viewing of data" (under Configure).

#### Shutting down:
````
python chords_control --stop  
````
* The CHORDS database will persist and be used the next time you run the CHORDS containers.


#### Updating:
````
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config  # Optional if you are using, and want to stick with, the 'latest' release
python chords_control --update
python chords_control --stop
python chords_control --run
````

#### Monitoring startup (optional):
* You can watch the startup log for the chords application. It's not critical,
  but can be useful for diagnosing problems, and for monitoring the tedious
  asset compilation process, which takes several minutes on the Raspberry Pi:  
````
docker logs -f chords_app
````

#### Visualization
Hit the _Visualization_ button to open a tab pointing to the builtin Grafana server.

Login with admin/<CHORDS_ADMIN_PW> to begin configuring Grafana (login on the Raspbery Pi is admin/changeme).

The [Getting Started Guide](http://docs.grafana.org/guides/getting_started/) is a good place to begin
learning about Grafana.

### Tips
* You reconfigure the portal using ```python chords_control --config```. Backup copies of the configuration
files are created in case you need to go back. Once you have set the CHORDS admin password and the secret key base,
you should not change them. Otherwise, the Rails application will not be able to access the CHORDS databases.

* If you sleep the machine that is running docker, the docker engine time can be wrong when the machine resumes, and so the container times will be wrong. The observable symptom is that the dashboard will not display correctly, since the data queries  are made relative to the current system time. The only fix is to restart the docker engine. The clock sync problem is mentioned on the forums, with the claim that they are working on the issue.

* _Note:_: If you find that localhost is not responding, try bringing CHORDS down and back up.

### More Information  
* More [CHORDS Docker tips](https://github.com/NCAR/chords/wiki/Docker-Details-and-Tips) are available on the project wiki.
* The CHORDS docker images are served from Docker Hub [repository](https://hub.docker.com/r/ncareol/chords_app/).
