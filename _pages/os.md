---
layout: single
title: Install CHORDS For Various Operating Systems
permalink: /gettingstarted/os/
classes: wide
---

<div id="tabs">
  <ul>
    <li><a href="#tabs-Ubuntu" style="background: none repeat scroll 0% 0% rgb(176,224,230);">Ubuntu</a></li> <!-- Using JqueryUI to set names and colors on the tabs -->
    <li><a href="#tabs-RHEL" style="background: none repeat scroll 0% 0% rgb(176,224,230);" >RHEL & Centos</a></li>
    <li><a href="#tabs-Macos" style="background: none repeat scroll 0% 0% rgb(176,224,230);">Mac</a></li>
    <li><a href="#tabs-W10" style="background: none repeat scroll 0% 0% rgb(176,224,230);">W10</a></li>
  </ul>

  <div id="tabs-Ubuntu"> <!-- content under tab -->
  <div id="ub" class="tab-pane active">
  {% highlight sh %}
sudo -i
apt-get install docker.io docker-compose git python-pip
  {% endhighlight %}
  {% include chords_control.md %}
  </div>
  </div>

  <div id="tabs-RHEL"> <!-- content under tab -->
  <div id="centos7" class="tab-pane">
  {% highlight sh %}
sudo -i # Or 'su -' if you do not have sudo privileges
yum -y install epel-release
yum -y install docker docker-compose
yum -y install git
yum -y install python2-pip
systemctl enable docker
systemctl start docker
  {% endhighlight %}
  {% include chords_control.md %}
  </div>
  </div>

  <div id="tabs-Macos"> <!-- content under tab -->
  <div id="macos" class="tab-pane">
  <ol>
  <li>Install <a href="https://docs.docker.com/v17.09/docker-for-mac/install/">Docker for Mac</a>.</li>
  <li>Run Docker. Configure its preferences to start Docker automatically. </li>
  <li>Note when you see the whale in the menu bar (upper right corner of your screen) docker is up and running!</li>
  <li>Then in a terminal window:
  {% highlight sh %}
mkdir chords
cd chords

# Fetch the control script:
pip install sh
curl -O -k https://raw.githubusercontent.com/NCAR/chords/master/chords_control

# Initial installation:
python chords_control --config
python chords_control --update

# To run CHORDS:
python chords_control --run

# To stop CHORDS:
python chords_control --stop

# To reconfigure and update:
cd chords
curl -O -k  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --stop
python chords_control --run
{% endhighlight %} 
</li>
<li> Once the above script has been run all you need to do to start chords on your computer again is open the terminal and type </li>
{% highlight sh %}
cd chords
python chords_control -- run
{% endhighlight %}
<embed src="https://www.youtube.com/embed/jR_XToKChYI" allowfullscreen="true" width="425" height="344">
  </ol>
  </div>
  </div>

  <div id="tabs-W10"> <!-- content under tab -->
  <ol>
  <li>Create a directory for chords files. The name and location are not important, but we suggest that you name it 'chords', and create it in your home directory.</li>

  <li>Download  and extract <a href="https://curl.haxx.se/windows/" target="_blank">curl</a>. Copy the files (curl.exe, etc.) in the 'bin' directory to your chords directory. For help with curl, visit this <a href="https://www.youtube.com/watch?v=8f9DfgRGOBo">video</a>.</li>

  <li>Download the<a href="https://www.python.org/ftp/python/2.7.16/python-2.7.16.amd64.msi">Windows Python 2 installer</a>. Double click on the downloaded .msi file to install it.</li>

  <li>Add Python paths to the Path environment variable. Hints:
  <ul>
    <li>Open the Start Search, type in “env”, and choose “Edit the system environment variables”: Click the “Environment Variables…” button.</li>
    <li>Under the "User Variables” section (the upper half), find the row with “Path” in the first column, and click edit. “Edit environment variable”will appear.</li>
    <li>Select "New", and enter the Python directory. This will usually be C:\Python27.</li>
    <li>Select "New", and enter the Python scripts directory. This will usually be C:\Python27\scripts.</li>
    <li>Ok->Ok->Ok.</li>
  </ul>
  </li>

  <li>Open a command window, verify that python is working, and install sh:
  {% highlight python %} 
python
Python 2.7.16 (v2.7.16:413a49145e, Mar  4 2019, 01:37:19) [MSC v.1500 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>> quit()
{% endhighlight %}
  </li>

  <li>Install <a href="https://docs.docker.com/docker-for-windows/install/" target="_blank">Docker Desktop for Windows</a>. (You will be required to create a free docker hub account, and log into it.)</li>

  <li>Run the Docker Desktop. It may take a minute to start up.</li>

  <li>Open a command window, and verify that docker is working:
  {% highlight sh %} 
docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
 {% endhighlight %} </li>

  <li>Install CHORDS from the command window:
  {% highlight sh %}
cd chords

# Fetch the control script:
curl -O -k https://raw.githubusercontent.com/NCAR/chords/master/chords_control

# Initial installation:
python chords_control --config
python chords_control --update

# To run CHORDS:
python chords_control --run

# To stop CHORDS:
python chords_control --stop

# To reconfigure and update:
cd chords
python chords_control --renew
python chords_control --config
python chords_control --update
python chords_control --stop
python chords_control --run
  {% endhighlight %} 
  </li>
  <li> Once the above script has been run all you need to do to start chords on your computer again is open the terminal and type </li>
  {% highlight sh %}
  cd chords
  python chords_control -- run
  {% endhighlight %}
  </ol>

  </div>
</div>
See the [detailed instructions](control.html) if the Quick Start recipes are not adequate
to get your portal running, and for additional information.
<script>
$("#tabs").tabs();
</script>

