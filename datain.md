---
layout: page
title: Data In
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
    <li><a data-toggle="tab" href="#browser">Browser and Sh</a></li>
    <li><a data-toggle="tab" href="#python">Python</a></li>
    <li><a data-toggle="tab" href="#c">C</a></li>
  </ul>

  <div class="tab-content">
  
    <div id="python" class="tab-pane">
      {% highlight python %}
#!/usr/bin/python

# Put a collection of measurements into the portal
import requests
url = 'http://my-chords-portal.com/measurements/url_create?instrument_id=3&t=27.1&rh=55&p=983.1&ws=4.1&wd=213.5&key=1762341'
response = requests.get(url=url)
print response
...
<Response [200]>
      {% endhighlight %}
    </div>

    <div id="browser" class="tab-pane active">
    <p>
    Data can be submitted to a portal just by typing the URL into the address bar of a browser. It's
    unlikely that you would use this method for any serious data collection!
    </p>
    <img  class="img-responsive" src="images/browserin.png" alt="CHORDS Portal Cartoon" >
    <p>
    The <em>wget</em> and <em>curl</em> commands, available in Linux and OSX, can accomplish the same thing 
    from a console. 
    </p>
    {% highlight sh %}
wget http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F461B1
    
curl http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F461B1
    {% endhighlight %}
  </div>

    <div id="c" class="tab-pane">
    <p>
    This example uses the <a href="http://curl.haxx.se/libcurl/c/libcurl.html">libCurl</a> library in a 
    C program to send a measurement URL to a portal. 
    </p>
    {% highlight c %}
#include <stdio.h>
#include <curl/curl.h>
 
int main(void)
{
  CURL *curl;
  CURLcode res;
 
  curl = curl_easy_init();
  if(curl) {
    char* url = "http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&key=A5F461B1";
    curl_easy_setopt(curl, CURLOPT_URL, url);
    /* example.com is redirected, so we tell libcurl to follow redirection */ 
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
 
    /* Perform the request, res will get the return code */ 
    res = curl_easy_perform(curl);
    /* Check for errors */ 
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));
 
    /* always cleanup */ 
    curl_easy_cleanup(curl);
  }
  return 0;
}
{% endhighlight %}
  </div>
</div>



