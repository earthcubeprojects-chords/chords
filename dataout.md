---
layout: page
title: Data Out
---

It's just as easy to get data out of a Portal as it is to put data in. This can
be done directly from the Portal web page. Or you can use HTTP URL's to
fetch data. The URL can be submitted directly from the address bar of your browser, which will
deliver the data in standard formats such as CSV files, JSON files, or plain JSON.

You can also retrieve data using your favorite programming language to construct
a program to send URLs and receive data, letting you build
analysis and visulaization apps that can process your real-time observations. Using JavaScipt,
you can even build widgets and pages that display your data on your own web site.

We will first describe the URL syntax for retrieving data, and follow this with examples that
demonstrate how easy it is to integrate your analysis activities with a CHORDS Portal using
Python, HTML, IDL, Matlab, R, sh, etc. You get the idea.

###  URL Syntax

Sample URLs for fetching data from the Portal:

    http://myportal.org/instruments/1.csv
    http://myportal.org/instruments/1.csv?start=2015-08-01T00:30&end=2015-08-20T12:30
    http://myportal.org/instruments/4.geojson?email=[USER_EMAIL]&api_key=[API_KEY]
    http://myportal.org/instruments/3.xml
    http://myportal.org/instruments/3.json?last

_myportal.org_ is the hostname of your Portal. The fields after "?" are quallifiers, each
separated by "&".

The number following _instruments/_ is the instrument identifier.

Following the instrument identifier is the format that the data will be returned in (_csv, geojson, json or xml_).

Some formats result in a data file being returned to you browser, which can be saved
in a directory. The other formats directly return text, which can
be easily ingested into programs.

<table class="table table-striped">
  <thead>
    <tr>
      <th>Format</th>
      <th>File or Text</th>
      <th>Data Product</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>.csv</td>
      <td>File</td>
      <td>Data in a comma-separated-value GeoCSV (CSV) file. CSV files can be opened automatically
          by spreadsheet programs such as MS Excel.</td>
    </tr>
    <tr>
      <td>.geojson</td>
      <td>File</td>
      <td>Data in a GeoJSON structured file, following RFC 7946. Most scripting programs can easily read JSON
          into a structured variable.</td>
    </tr>
    <tr>
      <td>.xml</td>
      <td>File</td>
      <td>Data in an eXtensible-Markup-Language (XML) structured file.</td>
    </tr>
    <tr>
      <td>.json</td>
      <td>Text</td>
      <td>Data in straight JSON format. This format is used to bring data directly into a
          processing program.</td>
    </tr>
  </tbody>
</table>

Fields after "?" are quallifier pairs, with each separated by "&". The qualifiers are
optional, and are used to refine the data request.

If time qualifiers are not specified, data for the curent day are returned.

<table class="table table-striped">
  <thead>
    <tr>
      <th>Qualifier</th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>start=time</td>
      <td>Start time of the data span, in <a href="https://en.wikipedia.org/wiki/ISO_8601">ISO8061</a> format.</td>
    </tr>
    <tr>
      <td>end=time</td>
      <td>Start time of the data span, in <a href="https://en.wikipedia.org/wiki/ISO_8601">ISO8061</a> format.</td>
    </tr>
    <tr>
      <td>email=[USER_EMAIL]</td>
      <td>If the Portal has been configured to require a security key for downloading data, the user email must also be specified with the <em>email</em> qualifier.</td>
    </tr>
    <tr>
      <td>api_key=[API_KEY]</td>
      <td>If the Portal has been configured to require a security key for downloading data, it
      is specified with the <em>api_key</em> qualifier. Keys are case sensitive and must be paired with the user email associated with the api key.</td>
    </tr>
  </tbody>
</table>

### Programming Examples

<ul class="nav nav-pills">
  <li class="active"><a data-toggle="tab" href="#browser">Browser</a></li>
  <li><a data-toggle="tab" href="#python">Python</a></li>
  <li><a data-toggle="tab" href="#htmlajax">HTML/JavaScript</a></li>
  <li><a data-toggle="tab" href="#idl">IDL</a></li>
  <li><a data-toggle="tab" href="#matlab">Matlab</a></li>
  <li><a data-toggle="tab" href="#r">R</a></li>
  <li><a data-toggle="tab" href="#sh">Sh</a></li>
</ul>

<div class="tab-content">

  <div id="browser" class="tab-pane active">
    <p>Use the "Data" link on the Portal to fetch daily data files using your browser.
    Various file formats can be selected.</p>
    <img class="img-responsive" src="images/data.png" alt="Direct">
  </div>

  <div id="python" class="tab-pane">
{% highlight python %}
# Fetch the most recent measurements from a portal
import json, requests
url      = 'http://my-chords-portal.com/instruments/3.geojson?last'
response = requests.get(url=url)
data     = json.loads(response.content)
print json.dumps(data, indent=4, sort_keys=True)
...
{
    "features": [
        {
            "geometry": {
                "coordinates": [
                    "-110.0",
                    "40.0",
                    "10.0"
                ],
                "type": "Point"
            },
            "properties": {
                "affiliation": "CHORDS Demo",
                "data": [
                    {
                        "test": "true",
                        "time": "2018-08-02T02:07:04Z",
                        "vars": [
                            {
                                "units": "mm",
                                "value": 0,
                                "variable_name": "Rain",
                                "variable_shortname": "rain"
                            }
                        ]
                    }
                ],
                "instrument": "TestWX1",
                "instrument_id": 1,
                "measurements_in_file": 1,
                "project": "CHORDS Demo",
                "site": "Test1",
                "site_id": 1
            },
            "type": "Feature"
        }
    ],
    "type": "FeatureCollection"
}{% endhighlight %}
  </div>

  <div id="htmlajax" class="tab-pane">

  <p><em>It appears that there may be cross-domain security issues with this approach. We need to
  look into this.</em></p>

{% highlight html %}
<h1>CHORDS HTML/Ajax Example</h1>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>

<script>
var url = "http://myportal.org/instruments/26.geojson?last";
$(function () {
    $.getJSON(url, function (data) {
        var table_html = "<table>";
        $.each(data,
        function (key, val) {
            if (key != "data") {
                table_html += "<tr><td>" + key + "</td><td>" + val + "</td></tr>";
            } else {
                $.each(val, function (datakey, dataval) {
                    table_html += "<tr><td>data</td><td>" + datakey
                      + "</td><td>" + dataval + "</td></tr>";
                });
            }
        });
        table_html += "</table>";

        $("<p>", {
            html: table_html
        }).appendTo("body");
    });
});
</script>
{% endhighlight %}
    Result:
    <img class="img-responsive" src="images/chords_ajax.png" alt="AJAX">
  </div>

  <div id="idl" class="tab-pane">
{% highlight idl %}
url='http://myportal.org/instruments/26.geojson?last'
oUrl = OBJ_NEW('IDLnetUrl')
json_data = oUrl->Get(URL=url, /STRING_ARRAY)
data = JSON_PARSE(json_data)
data.features.properties
...
{
    "Project": "CHORDS Testbed",
    "Site": "NCAR Mesa Lab",
    "Affiliation": "NSF EarthCube",
    "Instrument": "ML Wx Station",
    "Data": [
        {
            "test": "true",
            "time": "2018-08-02T02:07:04Z",
            "vars": [
                {
                    "units": "mm",
                    "value": 0,
                    "variable_name": "Rain",
                    "variable_shortname": "rain"
                }
            ]
        }
    ]
}
{% endhighlight %}
  </div>

  <div id="matlab" class="tab-pane">
{% highlight matlab %}
% Read CHORDS JSON data into a Matlab program.
% This code uses the JSONlab toolbox from the Matlab File Exchange.
% (Matlab >= R2014b)
url='http://myportal.org/instruments/26.geojson?last';
json_data = urlread(url);
inst_data =loadjson(json_data);
inst_data
inst_data.features.properties.data
...
inst_data.features.properties =

        Project: 'CHORDS Testbed'
           Site: 'NCAR Mesa Lab'
    Affiliation: 'NSF EarthCube'
     Instrument: 'ML Wx Station'
           Data: [1x1 struct]

ans =

       Time: {'2015-07-28T21:00:51.000Z'}
       wdir: 135
       wspd: 1.4000
       wmax: 4.3000
       tdry: 26.3000
         rh: 24.7000
       pres: 814.6000
    raintot: 453.7000
       batv: 13.9000

>>
{% endhighlight %}
  </div>

  <div id="r" class="tab-pane">
{% highlight r %}
install.packages('curl')
install.packages('jsonlite')
library('jsonlite')

url <- 'http://myportal.org/instruments/26.geojson?last'
data <- fromJSON(txt=url)
data
...
$Project
[1] "CHORDS Testbed"

$Site
[1] "NCAR Mesa Lab"

$Affiliation
[1] "NSF EarthCube"

$Instrument
[1] "ML Wx Station"

$Data
$Data$Time
[1] "2015-07-28T21:35:51.000Z"

$Data$wdir
[1] 80

$Data$wspd
[1] 3

$Data$wmax
[1] 5.8

$Data$tdry
[1] 25.7

$Data$rh
[1] 24.4

$Data$pres
[1] 814.4

$Data$raintot
[1] 453.7

$Data$batv
[1] 13.9
{% endhighlight %}
  </div>

  <div id="sh" class="tab-pane">
{% highlight sh %}
#!/bin/sh

urlcsv='http://myportal.org/instruments/26.csv?last'
urljson='http://myportal.org/instruments/26.geojson?last'

echo 'CSV format:'
curl $urlcsv

echo 'GeoJSON format:'
curl $urljson

echo
...

CSV format:
Project,CHORDS Testbed
Site,NCAR Mesa Lab
Affiliation,NSF EarthCube
Instrument,ML Wx Station
Time,Wind Direction,Wind Speed,Wind Max,Temperature,Humidity,Pressure,Rain Total,Battery
2015-07-28 22:30:51 UTC,75.0,2.5,6.4,26.3,25.3,814.3,453.7,13.9

GeoJSON format:
{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":["-110.0","40.0","10.0"]},"properties":{"project":"CHORDS Demo","affiliation":"CHORDS Demo","site":"Test1","site_id":1,"instrument":"TestWX1","instrument_id":1,"measurements_in_file":1,"data":[{"time":"2018-08-02T02:07:04Z","test":"true","vars":[{"variable_name":"Rain","variable_shortname":"rain","units":"mm","value":0}]}]}}]}
{% endhighlight %}
  </div>
</div>




