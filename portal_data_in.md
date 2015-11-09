---
layout: page
title: Putting Data Into a CHORDS Portal
---

It's easy to submit new data to a Portal, simply using standard HTTP URL's. The URL can be submitted 
directly from the address bar of your browser (but of course this would get tedious).

Almost all programming languages have functions for submitting HTTP requests. We will first describe 
the URL syntax, and follow this with examples that demonstrate how easy it is to feed your
data to a CHORDS Portal, using [Python](#python) or a [browser/command line](#browser). These aren't
the only languages that work, and you should be able to figure out a similar method for your own
particular langauge.

**Insert a description of the URL put syntax here**

## <a name="python"></a>Python

{% highlight python %}
# Put a collection of measurements into the portal
import requests
url = 'http://my-chords-portal.com/measurements/url_create?instrument_id=3&t=27.1&rh=55&p=983.1&ws=4.1&wd=213.5&key=1762341'
response = requests.get(url=url)
print response
...
<Response [200]>
{% endhighlight %}

## <a name="browser"></a>Browser and sh

Data can be submitted to a portal just by typing the URL into the address bar. The *wget* and *curl* commands, avaiable in Linux and OSX, can accomplish the same thing. The following shows a typical URL submitted with *wget* or *curl*.

{% highlight sh %}
wget http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F4&&B1

curl http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F4&&B1
{% endhighlight %}
