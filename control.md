---
layout: page
title: CHORDS Setup and Control
---

CHORDS is packaged as a collection of [Docker containers](https://hub.docker.com/r/ncareol/chords/). 
Configuration and control of these containers are performed by running a python management script. The script
shares the directory containing CHORDS configuration files.

_Note: On systems where docker requires root, you may need to use sudo to run these commands._

#### Requirements:
 * python 2.7 (Linux and MacOS have this by default; [install](https://www.python.org/downloads/windows/) on Windows)
 * curl (Linux and MacOS have this by default; [install](https://help.zendesk.com/hc/en-us/articles/229136847-Installing-and-using-cURL#install) on Windows)
 * A running docker system
   * OSX: [Docker for Mac](https://docs.docker.com/engine/installation/mac/#/docker-for-mac) is fantastic on the Mac.
   * W10 Pro: [Docker for Windows](https://docs.docker.com/engine/installation/windows/#/docker-for-mac)
   * W7: For us hapless Windows 7 users, we have to use the less elegant [Docker Toolbox](https://docs.docker.com/engine/installation/windows/#/docker-toolbox). 
   * Linux: See [instructions](https://docs.docker.com/engine/installation/linux/) for various flavors of this OS.
   * Raspberry Pi: See the easy to follow [instructions](https://github.com/NCAR/chords/wiki/Docker-on-Raspberry-Pi) for bringing up a Docker enabled
   Raspberry Pi.
 * Port 25 must be open. Port 3000 must be open for the Grafana visualization, but you can use CHORDs without this 
   feature.

#### Installation:
{% highlight sh %}
# Select the configuration directory
cd <configuration directory>

# Fetch the CHORDS management script
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control

# Create configuration files (_chords.yml_ and _.env_ will be created)
# (Be prepared to enter an admin password of your choosing.)
python chords_control --config

# Update the CHORDS software
python chords_control --update
{% endhighlight %}
#### Running:
{% highlight sh %}
python chords_control --run
{% endhighlight %}

#### Verifying:
* Point your browser at the CHORDS portal by entering the IP address of the system into the address bar. This may be
_localhost_ if CHORDS is on the same machine as you browser. On W7 machines, get the IP from the output of: 
````docker-machine ip````
* It can take quite a while for the initial page load to finish, as the server initializes its caches. A
Raspberry Pi can take up to a couple of minutes. 
* Sign in with admin@chordsrt.com (realtimedata). Immediately change this admin account password (under Users). You will
  probably also want to uncheck "Restrict viewing of data" (under Configure).

#### Shutting down:
{% highlight sh %}
python chords_control --stop  
{% endhighlight %}
* The CHORDS database will persist and be used the next time you run the CHORDS containers.


#### Updating:
{% highlight sh %}
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config  # Optional if you are using, and want to stick with, the 'latest' release
python chords_control --update
python chords_control --stop
python chords_control --run
{% endhighlight %}

#### Monitoring:
* You can watch the startup log for the chords application. It's not critical,
  but can be useful for diagnosing problems, and for monitoring the tedious
  asset compilation process, which takes several minutes on the Raspberry Pi:  
{% highlight sh %}
docker logs -f chords_app
{% endhighlight %}

#### Visualization
Hit the _Visualization_ button to open a tab pointing to the builtin Grafana server.

Login with admin/<CHORDS_ADMIN_PW> to begin configuring Grafana (login on the Raspbery Pi is admin/changeme).

The [Getting Started Guide](http://docs.grafana.org/guides/getting_started/) is a good place to begin
learning about Grafana. There is also a [very useful tutorial](http://docs.grafana.org/features/datasources/influxdb/)
for configuring the dashboard queris. Data Source parameters are:

<table class="table table-striped">
  <thead>
    <tr>
      <th>Parameter</th>
      <th>Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Name</td>
      <td>CHORDS</td>
    </tr>
    <tr>
      <td>Type</td>
      <td>InfluxDB</td>
    </tr>
    <tr>
      <td>URL</td>
      <td>http://localhost:8086</td>
    </tr>
    <tr>
      <td>Access</td>
      <td>direct</td>
    </tr>
    <tr>
      <td>Database</td>
      <td>chords_ts_production</td>
    </tr>
    <tr>
      <td>User</td>
      <td>guest:guest</td>
    </tr>
  </tbody>
</table>


### Tips
* You reconfigure the portal using ```python chords_control --config```. Backup copies of the configuration
files are created in case you need to go back. Once you have set the CHORDS admin password and the secret key base,
you should not change them. Otherwise, the Rails application will not be able to access the CHORDS databases.

* If you sleep the machine that is running docker, the docker engine time can be wrong when the machine resumes, and so the container times will be wrong. The observable symptom is that the dashboard will not display correctly, since the data queries  are made relative to the current system time. The only fix is to restart the docker engine. The clock sync problem is mentioned on the forums, with the claim that they are working on the issue.

* _Note:_: If you find that localhost is not responding, try bringing CHORDS down and back up.

### More Information  
* More [CHORDS Docker tips](https://github.com/NCAR/chords/wiki/Docker-Details-and-Tips) are available on the project wiki.
* The CHORDS docker images are served from Docker Hub [repository](https://hub.docker.com/r/ncareol/chords_app/).
