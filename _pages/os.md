---
layout: single
title: Install CHORDS For Various Operating Systems
permalink: /gettingstarted/os/
---

## Accordion Demo
<div id="accordion">
  <h3>Ubuntu</h3>
  <div>
    <p>Mauris mauris ante, blandit et, ultrices a, suscipit eget, quam. Integer
    ut neque. Vivamus nisi metus, molestie vel, gravida in, condimentum sit
    amet, nunc. Nam a nibh. Donec suscipit eros. Nam mi. Proin viverra leo ut
    odio. Curabitur malesuada. Vestibulum a velit eu ante scelerisque vulputate.</p>

    <p>Sed non urna. Donec et ante. Phasellus eu ligula. Vestibulum sit amet
    purus. Vivamus hendrerit, dolor at aliquet laoreet, mauris turpis porttitor
    velit, faucibus interdum tellus libero ac justo. Vivamus non quam. In
    suscipit faucibus urna.</p>
  </div>
  <h3>RHEL & Centos</h3>
  <div>
    <p>Sed non urna. Donec et ante. Phasellus eu ligula. Vestibulum sit amet
    purus. Vivamus hendrerit, dolor at aliquet laoreet, mauris turpis porttitor
    velit, faucibus interdum tellus libero ac justo. Vivamus non quam. In
    suscipit faucibus urna.</p>

    <p>Mauris mauris ante, blandit et, ultrices a, suscipit eget, quam. Integer
    ut neque. Vivamus nisi metus, molestie vel, gravida in, condimentum sit
    amet, nunc. Nam a nibh. Donec suscipit eros. Nam mi. Proin viverra leo ut
    odio. Curabitur malesuada. Vestibulum a velit eu ante scelerisque vulputate.</p>
  </div>
</div>

## Tabs Demo
<div id="tabs">
  <ul>
    <li><a href="#tabs-Ubuntu">Ubuntu</a></li>
    <li><a href="#tabs-RHEL">RHEL & Centos</a></li>
    <li><a href="#tabs-W10">W10</a></li>
  </ul>
  <div id="tabs-Ubuntu">
    Proin elit arcu, rutrum commodo, vehicula tempus, commodo a, risus. Curabitur nec arcu. Donec sollicitudin mi sit amet mauris. Nam elementum quam ullamcorper ante. Etiam aliquet massa et lorem. Mauris dapibus lacus auctor risus. Aenean tempor ullamcorper leo. Vivamus sed magna quis ligula eleifend adipiscing. Duis orci. Aliquam sodales tortor vitae ipsum. Aliquam nulla. Duis aliquam molestie erat. Ut et mauris vel pede varius sollicitudin. Sed ut dolor nec orci tincidunt interdum. Phasellus ipsum. Nunc tristique tempus lectus.
  </div>
  <div id="tabs-RHEL">
    Morbi tincidunt, dui sit amet facilisis feugiat, odio metus gravida ante, ut pharetra massa metus id nunc. Duis scelerisque molestie turpis. Sed fringilla, massa eget luctus malesuada, metus eros molestie lectus, ut tempus eros massa ut dolor. Aenean aliquet fringilla sem. Suspendisse sed ligula in ligula suscipit aliquam. Praesent in eros vestibulum mi adipiscing adipiscing. Morbi facilisis. Curabitur ornare consequat nunc. Aenean vel metus. Ut posuere viverra nulla. Aliquam erat volutpat. Pellentesque convallis. Maecenas feugiat, tellus pellentesque pretium posuere, felis lorem euismod felis, eu ornare leo nisi vel felis. Mauris consectetur tortor et purus.
  </div>
  <div id="tabs-W10">
    <p>Mauris eleifend est et turpis. Duis id erat. Suspendisse potenti. Aliquam vulputate, pede vel vehicula accumsan, mi neque rutrum erat, eu congue orci lorem eget lorem. Vestibulum non ante. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Fusce sodales. Quisque eu urna vel enim commodo pellentesque. Praesent eu risus hendrerit ligula tempus pretium. Curabitur lorem enim, pretium nec, feugiat nec, luctus a, lacus.</p>

    <p>Duis cursus. Maecenas ligula eros, blandit nec, pharetra at, semper at, magna. Nullam ac lacus. Nulla facilisi. Praesent viverra justo vitae neque. Praesent blandit adipiscing velit. Suspendisse potenti. Donec mattis, pede vel pharetra blandit, magna ligula faucibus eros, id euismod lacus dolor eget odio. Nam scelerisque. Donec non libero sed nulla mattis commodo. Ut sagittis. Donec nisi lectus, feugiat porttitor, tempor ac, tempor vitae, pede. Aenean vehicula velit eu tellus interdum rutrum. Maecenas commodo. Pellentesque nec elit. Fusce in lacus. Vivamus a libero vitae lectus hendrerit hendrerit.</p>

  </div>
</div>

----
See the [detailed instructions](control.html) if the Quick Start recipes are not adequate
to get your portal running, and for additional information.

### Quick Start
<ul class="nav nav-pills">
  <li class="active"><a data-toggle="tab" href="#ub">Ubuntu</a></li>
  <li><a data-toggle="tab" href="#centos7">RHEL/CentOS 7</a></li>
  <li><a data-toggle="tab" href="#macos">MacOS</a></li>
  <li><a data-toggle="tab" href="#w10">W10</a></li>
  <!--<li><a data-toggle="tab" href="#w7">W7</a></li> -->
</ul>

<div class="tab-content">

<div id="ub" class="tab-pane active">
{% highlight sh %}
sudo -i
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
<li>Install <a href="https://docs.docker.com/v17.09/docker-for-mac/install/">Docker for Mac</a>.</li>
<li>Run Docker. Configure its preferences to start Docker automatically. </li>
<li>Then in a terminal window:
{% include chords_control.md %}
</li>
</ul>
</div>
  
<div id="w10" class="tab-pane">
<ul>
<li>Install <a href="https://docs.docker.com/docker-for-windows/">Docker for Windows</a></li>
<li>Run Docker  (it may take a minute to start up).</li>
<li>Install <a href="https://www.python.org/downloads/windows/">Python 2.7.</a></li>
<li>Unpack <a href="https://curl.haxx.se/download.html">curl.</a> into a directory of your choice.</li>
<li>Add C:\Python27 to the Path environment variable.</li>
<li>Add the curl directory to the Path environment variable.</li>
<li>Open a PowerShell or Command Line, and:
{% include chords_control.md %} </li>
</ul>
</div>
  
<!-- Users don't use W7 anymore if there is a user who does I recommend a Virtual machine with a more updated OS -->
<!-- <div id="w7" class="tab-pane">
{% highlight sh %}
Docker engine
{% endhighlight %}
<ul><li> Now point your browser at the IP of the the system. <strong>Be sure to use http:// (not https://)</strong>.</li></ul>
</div> -->

</div>
<script>
$("#accordion").accordion();
$("#tabs").tabs();
</script>
    