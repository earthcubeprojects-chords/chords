---
layout: page
title: What is CHORDS?
---

<div class="well" style="text-align: center;">
  You put data into CHORDS like this:<br/>http://myportal.org/measurements/url_create?instrument_id=25&wdir=038&wspd=3.2
</div>

<div class="well" style="text-align: center;">
  You get data out of CHORDS like this:<br/>http://myportal.org/instruments/25.csv
</div>

From the [NSF EarthCube project](http://earthcube.org/group/chords), "Cloud-Hosted Real-time Data Services for the Geosciences (CHORDS) is a real-time data services infrastructure that will provide an easy-to-use system to acquire, navigate and distribute real-time data streams via cloud services and the Internet. It will lower the barrier to these services for small instrument teams, employ data and metadata formats that adhere to community accepted standards, and broaden access to real-time data for the geosciences community."

*The CHORDS Portal is being developed under NSF grant funding, **it is currently a prototype development**, 
and is not guarenteed to be bug free.
Even so, this work has already produced a capable, stable and useful product. The Portal is productively 
employed by many "friendly testers", and we encourage you to use it, appreciate the simplicity that it brings
to real-time data distribution, and provide us with feedback on how it can be improved.*

CCHORDS consists of two components: 

* a real-time instrument data management server (_Portal_)
* a collection of higher level web-services that provide advanced, standards based processing (_Services_).

<span class="badge center-block">This web site is about the CHORDS Portal</span>

<img  class="img-responsive" src="images/overview.png" alt="CHORDS Portal Cartoon" >
## The CHORDS Portal is a
 
* **web server and database** that accepts real-time data from distributed instruments, and serves 
the measurements to anyone on the Internet. The data streams are pushed to and pulled from the Portal using 
simple HTTP requests.
* **management tool** that allows you to monitor your remote instruments, insure correct operation, and maximize data collection.
* **rolling archive** from which scientists and analysts can easily fetch the data in
real-time, delivered directly to browsers, programs and mobile apps. It will only hold a
certain amount of data, but usually enough to give you plenty of time (e.g. months) to 
transfer to your own archive system. One click brings you a CSV file. A few lines of code brings data directly into your analysis programs.
* **entry point** to sophisticated real-time web services that can convert your data streams to
standardized formats such as OGC, and provide mapping, visualization, discovery, aggregation and 
many other web-enabled functions. 

**Note that a CHORDS Portal is not meant to be a permanent archive. Users should plan to download and save data that they
want to keep perminently**.

## Owning a Portal

The Portal is targeted at users who do not have IT staffs and budgets. It is an appliance which you 
run on Amazon Web Services:

* **Ownership:** You have complete control of the portal. You create it and manage it yourself, without
having to rely on external tech support.
* **It's Cheap:** The portal, for a modest network of instruments (say 10), will cost about $0.50 a day to operate
on Amazon.
* **Setting It Up:** The one requirement is a credit card, to create an Amazon Web Services account. From
your account, you will follow a short recipe to create a new Portal (server) running on Amazon. 
You then go to your Portal web page and configure it for your project.

## The One Gotcha

Nothing is entirely free (unlike beer). You will need to adapt your instrument to send the URL's containing
your measurements, to your Portal. But usually this is not too hard. Your instrument may already 
have an Internet connection, and you just need to add a few lines to a processing script. Maybe you will need to
add a USB cell modem to your data acquisition computer. Or perhaps you need to add a $50 _Rasberry Pi_ to provide 
translation from an instrument to the network. Chances are that since you deploy instruments, you are already 
pretty handy in this area. In any event, we can offer advice on getting connected. And this web site already has
code examples for accessing the portal from many languages.

## Citing CHORDS and Sponsor Acknowledgements

CHORDS has been issued a Digital Object Identifier (DOI) from DataCite.org

We request that your cite its use in any relevant publication using this format:

<div class="well" style="text-align: left;">
  Cloud-Hosted Real-time Data Services for the Geosciences (Version 0.9) [Software]. (2017). Boulder, Colorado: UCAR/NCAR. http://dx.doi.org/10.5065/D6V1236Q
</div>

Please see [http://data.datacite.org/10.5065/D6V1236Q](http://data.datacite.org/10.5065/D6V1236Q) to view the relevant DOI metadata fields.

CHORDS is being developed for the National Science Foundation’s EarthCube program under grants 1639750, 1639720, 1639640, 1639570 and 1639554.

## Current and Future

At the moment the Portal only processes time-series measurements. We will soon be adding a data type for
soundings. Plans are under way to add additional data types, such as ray-oriented measurements and imagery.
And we are always open to suggestions for other observation types.

