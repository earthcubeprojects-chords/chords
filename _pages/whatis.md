---
layout: single
title: What is CHORDS?
header:
  overlay_color: "#000"
  overlay_filter: "0.5"
permalink: /whatis/
classes: wide
---


<div class="well" style="text-align: center;">
  You put data into CHORDS like this:<br/>http://myportal.org/measurements/url_create?instrument_id=25&wdir=038&wspd=3.2
</div>

<div class="well" style="text-align: center;">
  You get data out of CHORDS like this:<br/>http://myportal/api/v1/data/3.csv?last
</div>

**C**loud.**HO**sted.**R**eal-time.**D**ata.**S**ervices or **CHORDS** is a masterpiece of the [NSF EarthCube project](http://earthcube.org/group/chords). It is a real-time data service for the geosciences that provides an easy-to-use system to acquire, navigate, and distribute real-time data via cloud services and the Internet. CHORDS aims to lower the barrier to these services, especially for small instrument teams, and broaden access to real-time data for the geosciences community. 

*The CHORDS Portal is being developed under NSF grant funding and is not guaranteed to be bug free. Even so, this work has produced a capable, stable and useful product. CHORDS is productively employed by many “friendly users”, and we encourage you to use it, appreciate the simplicity that it brings to real-time data distribution, and provide us with feedback on how it can be improved. CHORDS consists of two components:*


* a real-time instrument data management server (_Portal_)
* a collection of higher level web-services that provide advanced, standards based processing (_Services_).

<!-- <span class="badge center-block">This web site is about the CHORDS Portal</span> -->
<figure>
  <a href = "{{ site.baseurl }}/assets/images/overview.png"><img  class="img-responsive" src="{{ site.baseurl }}/assets/images/overview.png" alt="CHORDS Portal Cartoon"></a><!--Using liquid to set path for images.-->
</figure>

## The CHORDS Portal:
* **web server and database** that accepts real-time data from distributed instruments and serves the measurements to anyone on the Internet. The data streams are pushed to and pulled from the portal using simple HTTP requests.

* **management tool** that allows you to monitor your remote instruments, ensure correct operation, and maximize data collection.

* **rolling archive**  from which scientists and analysts can easily fetch the data in real-time, delivered directly to browsers, programs, and mobile apps. It will only hold a certain amount of data, but usually enough to give you plenty of time (e.g. months) to transfer to your own archive system. One click brings you a CSV or GeoJSON file. A few lines of code brings data directly into your analysis programs.

* **entry point** to sophisticated real-time web services that can convert your data streams to standardized formats, and provide mapping, visualization, discovery, aggregation, and many other web-enabled functions.



## Current and Future
Currently, portals only process time-series measurements. Plans are underway to add additional data types, such as ray-oriented measurements and imagery. We are always open to suggestions for other observation types. You can send us suggestions or questions via email at [chords@ucar.edu](chords@ucar.edu) or visit us on our github [https://github.com/NCAR/chords](https://github.com/NCAR/chords). 

## Citing CHORDS and Sponsor Acknowledgements

CHORDS has been issued a Digital Object Identifier (DOI) from DataCite.org

We request that researchers cite its use in any relevant publication or other context using this format:

<div class="well" style="text-align: left;">
Daniels, M. D., Kerkez, B., Chandrasekar, V., Graves, S., Stamps, D. S., Martin, C., Botnick, A., Gooch, R., Bartos, M., Jones, J., Keiser, K. (2016). Cloud-Hosted Real-time Data Services for the Geosciences (CHORDS) software (Version 0.9). UCAR/NCAR - Earth Observing Laboratory. https://doi.org/10.5065/d6v1236q
</div>

Please see [http://data.datacite.org/application/vnd.datacite.datacite+json/10.5065/D6V1236Q](http://data.datacite.org/application/vnd.datacite.datacite+json/10.5065/D6V1236Q) to view the relevant DOI metadata fields.

CHORDS is being developed for the National Science Foundation’s EarthCube program under grants 1639750, 1639720, 1639640, 1639570 and 1639554.




