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
apt-get update
apt-get install docker.io docker-compose git
{% endhighlight %}
{% include chords_control.md %}
</div>

<div id="centos7" class="tab-pane">
{% highlight sh %}
sudo -i # Or 'su -' if you do not have sudo privileges
yum -y install epel-release
yum -y install docker docker-compose
yum -y install git
systemctl enable docker
systemctl start docker
{% endhighlight %}
{% include chords_control.md %}
</div>
  
<div id="macos" class="tab-pane">
<ul>
<li>Install <a href="https://download.docker.com/mac/stable/Docker.dmg">Docker for Mac</a>.</li>
<li>Run Docker. Configure its preferences to start Docker automatically. </li>
<li>Then in a terminal window:
{% include chords_control.md %}
</li>
</ul>
</div>
  
<div id="w10" class="tab-pane">
<ul>
<li>Install <a href="https://download.docker.com/win/stable/InstallDocker.msi">Docker for Windows</a></li>
<li>Run Docker  (it may take a minute to start up).</li>
<li>Install <a href="https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi">Python 2.7.</a></li>
<li>Unpack <a href="http://www.paehl.com/open_source/?download=curl_754_0_ssl.zip">curl.</a> into a directory of your choice.</li>
<li>Add C:\Python27 to the Path environment variable.</li>
<li>Add the curl directory to the Path environment variable.</li>
<li>Open a PowerShell, and:
{% include chords_control.md %} </li>
</ul>
</div>
  
<div id="w7" class="tab-pane">
{% highlight sh %}
Docker engine
{% endhighlight %}
<ul><li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li></ul>
</div>

</div>

 

