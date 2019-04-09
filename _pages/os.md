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
  <ul>
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
  </ul>
  </div>
  </div>

  <div id="tabs-W10"> <!-- content under tab -->
  <ul>
  <li>Install <a href="https://docs.docker.com/docker-for-windows/">Docker for Windows</a></li>
  <li>Run Docker  (it may take a minute to start up).</li>
  <li>Install the latest <a href="https://www.python.org/downloads/windows/">Python 2 release </a></li>
  <li>Download <a href="https://curl.haxx.se/download.html">curl.</a> into a directory of your choice.</li>
  <li>Add C:\Python to the Path environment variable.</li>
  <li>Add the curl directory to the Path environment variable.</li>
  <li>For help with curl visit this <a href="https://www.youtube.com/watch?v=8f9DfgRGOBo"> video </a></li>
  <li>Open Command Line, and type:
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
  </li>
  </ul>


  </div>
</div>
See the [detailed instructions](control.html) if the Quick Start recipes are not adequate
to get your portal running, and for additional information.
<script>
$("#tabs").tabs();
</script>

