---
layout: page
title: Install CHORDS For Various Operating Systems
---

See the [detailed instructions](control.html) if the Quick Start recipes are not adequate
to get your portal running, and for additional information.

### Quick Start
<ul class="nav nav-pills">
  <li class="active"><a data-toggle="tab" href="#ub">Ubuntu</a></li>
  <li><a data-toggle="tab" href="#centos7">RHEL/CentOS 7</a></li>
  <li><a data-toggle="tab" href="#macos">MacOS</a></li>
  <li><a data-toggle="tab" href="#w10">W10</a></li>
  <li><a data-toggle="tab" href="#w7">W7</a></li>
</ul>

<div class="tab-content">

<div id="ub" class="tab-pane active">
{% highlight sh %}
sudo -i
apt-get install docker.io docker-compose
{% endhighlight %}
{% include chords_control.md %}
<ul><li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li></ul>
</div>

<div id="centos7" class="tab-pane">
{% highlight sh %}
sudo -i
yum -y install docker docker-compose
systemctl enable docker
systemctl start docker
{% endhighlight %}
{% include chords_control.md %}
<ul><li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li></ul></div>
  
<div id="macos" class="tab-pane">
<ul>
<li>Install <a href="https://download.docker.com/mac/stable/Docker.dmg">Docker for Mac</a>.</li>
<li>Run Docker and configure the preferences to start it automatically. </li>
<li>Then in a terminal window:
{% include chords_control.md %}
</li>
<li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li>
</ul>
</div>
  
<div id="w10" class="tab-pane">
{% highlight sh %}
Docker for Windows
{% endhighlight %}
<ul><li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li></ul>
</div>
  
<div id="w7" class="tab-pane">
{% highlight sh %}
Docker engine
{% endhighlight %}
<ul><li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li></ul>
</div>

</div>

 

