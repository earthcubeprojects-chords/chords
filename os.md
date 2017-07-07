---
layout: page
title: Operating System Configuration
---

See the [detailed instructions](control.html) if the Quick Start recipes are not adequate
to get your portal running.

### Quick Start
<ul class="nav nav-pills md-2">
  <li class="active"><a data-toggle="tab" href="#ub">Ubuntu</a></li>
  <li><a data-toggle="tab" href="#centos">CentOS7</a></li>
  <li><a data-toggle="tab" href="#macos">MacOS</a></li>
  <li><a data-toggle="tab" href="#w10">W10</a></li>
  <li><a data-toggle="tab" href="#w7">W7</a></li>
</ul>

<div class="tab-content">

  <div id="ub" class="tab-pane" active>
    {% highlight sh %}
sudo -i
apt-get install docker.io docker-compose

mkdir <CHORDS config dir>
cd <CHORDS config dir>
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control

python chords_control --config
python chords_control --update
python chords_control --run

# To reconfigure/update:
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --stop
python chords_control --run
    {% endhighlight %}
  </div>

  <div id="centos" class="tab-pane">
    {% highlight sh %}
yum    
    {% endhighlight %}
  </div>
  
  <div id="macos" class="tab-pane">
  Install <a href="https://download.docker.com/mac/stable/Docker.dmg">Docker for Mac</a>. 
  
  Run Docker and configure it to start automatically. Then in a terminal window:
    {% highlight sh %}
mkdir <CHORDS config dir>
cd <CHORDS config dir>
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --run
# To reconfigure/update:
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --stop
python chords_control --run
    {% endhighlight %}
  </div>
  
  <div id="w10" class="tab-pane">
    {% highlight sh %}
Docker for Windows
    {% endhighlight %}
  </div>
  
  <div id="w7" class="tab-pane">
    {% highlight sh %}
Docker engine
    {% endhighlight %}
  </div>

</div>

 

