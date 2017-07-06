---
layout: page
title: Operating System Configuration
---

<ul class="nav nav-pills">
  <li class="active"><a data-toggle="tab" href="#ubunbtu"  >Ubuntu</a></li>
  <li>               <a data-toggle="tab" href="#centos"   >CentOS 7  </a></li>
  <li>               <a data-toggle="tab" href="#macos"    >MacOS 7   </a></li>
  <li>               <a data-toggle="tab" href="#windows10">w10</a>   </li>
  <li>               <a data-toggle="tab" href="#windows7" >w7</a>    </li>
</ul>

<div class="tab-content" active>
  <div id="ubuntu" class="tab-pane">
    {% highlight sh %}
sudo -i
apt-get install docker.io docker-compose
curl -O  https://raw.githubusercontent.com/NCAR/chords/master/chords_control
python chords_control --config
python chords_control --update
python chords_control --run
    {% endhighlight %}
  </div>

  <div id="centos" class="tab-pane">
    {% highlight sh %}
    {% endhighlight %}
  </div>
  
  <div id="macos" class="tab-pane">
    {% highlight sh %}
    {% endhighlight %}
  </div>
  
  <div id="w10" class="tab-pane">
    {% highlight sh %}
    {% endhighlight %}
  </div>
  
  <div id="w7" class="tab-pane">
    {% highlight sh %}
    {% endhighlight %}
  </div>
</div>
