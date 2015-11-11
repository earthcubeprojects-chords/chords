---
layout: page
title: Putting Data Into a CHORDS Portal
---

It's easy to submit new data to a Portal, simply using standard HTTP URL's. The URL can be submitted 
directly from the address bar of your browser (but of course this would get tedious).

Almost all programming languages have functions for submitting HTTP requests. We will first describe 
the URL syntax, and follow this with examples that demonstrate how easy it is to feed your
data to a CHORDS Portal, using Python or a browser/command line. These aren't
the only languages that work, and you should be able to figure out a similar method for your own
particular langauge.

**Insert a description of the URL put syntax here**

<div class="container">
  <ul class="nav nav-pills">
    <li><a data-toggle="tab" href="#python">Python</a></li>
    <li><a data-toggle="tab" href="#browser">Browser and Sh</a></li>
  </ul>

  <div class="tab-content">
  
    <div id="python" class="tab-pane active">
      {% highlight python %}
      # Put a collection of measurements into the portal
      import requests
      url = 'http://my-chords-portal.com/measurements/url_create?instrument_id=3&t=27.1&rh=55&p=983.1&ws=4.1&wd=213.5&key=1762341'
      response = requests.get(url=url)
      print response
      ...
      <Response [200]>
      {% endhighlight %}
    </div>

    <div id="browser" class="tab-pane">
    <p>
    Data can be submitted to a portal just by typing the URL into the address bar of a browser. 
    </p>
    <p>
    The <em>wget</em> and <em>curl</em> commands, available in Linux and OSX, can accomplish the same thing 
    from a console. The following shows a typical URL submitted with these commands.
    </p>
    {% highlight sh %}
wget http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F461B1
    
curl http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F461B1
    {% endhighlight %}
  </div>
</div>

