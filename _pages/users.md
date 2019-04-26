---
layout: single
title: Users
permalink: /users/
toc: true
toc_sticky: true
toc_label: "Table of Contents"
toc_icon: "cog"
---

## What can users do?

Users can create, view, and download data from CHORDS. However a person’s access level will determine the functions available. Permissions, such as data downloader, are enhancements on a registered user, while the guest user is equivalent to not being logged in.

### Guest

Guest User Can:
- Read About page
- View self information


### Registered User

Registered User Can:
- Read About page and view data
- View Site
- View Instruments
- Can View and edit self information


### Data Downloader

You guessed it. This option lets Registered Users view and download data from instruments.

A Data Downloader can:
- Download data
- View Instruments

1. Log into chords
2. Click on **“Data”** on the left side of your screen 
3. Select the dates that you want to download data from
4. Select the instruments you want to download data from OR click **“Select All”**

5. Click **“Download GeoJSON”**


### Measurement Creator

Measurement Creator can:
- Create instruments
- Create test measurements

As a measurement creator it is recommended that you keep this account separate from other accounts that are used for data downloading or just as a registered user. Doing so prevents security issues in the future. Each Measurement user has their own API key to send measurements. 

To find your api key: 
1. Log into chords with your measurement account
2. Click on **“Users”** on the upper right corner of the screen
3. Copy the randomly generated key under API key.

<font color="red">Note: </font>You should only have ONE API key per instrument. 



## Storing Measurements

### Sending a URL from UNIX

#### Data In
It is easy to submit new data to a Portal, simply using standard HTTP URLs. The URL can be submitted directly from the address bar of your browser (but of course this would get tedious).
We will first describe the URL syntax, and follow this with examples that demonstrate how easy it is to feed your data to a CHORDS Portal, using Python, C, a browser or the command line. These are only a few of the languages that work, and you should be able to figure out a similar method for your own particular language. Almost all programming languages have functions for submitting HTTP requests.

#### URL Syntax
Sample URLs for submitting measurements to the Portal:

```
http://myportal.org/measurements/url_create?instrument_id=[INST_ID]&wdir=038&wspd=3.2&at=2015-08-20T19:50:28
http://myportal.org/measurements/url_create?instrument_id=[INST_ID]&p=981.2&email=[USER_EMAIL]&api_key=[API_KEY]
http://myportal.org/measurements/url_create?instrument_id=[INST_ID]&p=981.2&email=[USER_EMAIL]&api_key=[API_KEY]&at=2015-08-20T19:50:28&test
```

*myportal.org* is the hostname of your Portal. The fields after “?” are qualifiers, each separated by “&”.
Measurements for variables are specified by *shortname=value* pairs. You do not need to include measurements for all variables defined for the instrument, if they are not available.

<table class="table table-striped">
  <thead>
    <tr>
      <th>Qualifier</th>
      <th>Optional</th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>instrument_id=id</td>
      <td>No</td>
      <td>The Portal assigned instrument identifier.</td>
    </tr>
    <tr>
      <td>at=time</td>
      <td>Yes</td>
      <td>Specify a timestamp to be applied to the measurements. If <em>at</em> is not specified,
      the measurement will be stamped with the time that it was received by the Portal (often
      quite adequate). The time format is <a href="https://en.wikipedia.org/wiki/ISO_8601">ISO8061</a>.</td>
    </tr>
    <tr>
      <td>email=[USER_EMAIL]</td>
      <td>Yes</td>
      <td>If the Portal has been configured to require a security key for incoming measurements, the user email, <em>email</em> qualifier is needed.</td>
    </tr>
    <tr>
      <td>api_key=[API_KEY]</td>
      <td>Yes</td>
      <td>If the Portal has been configured to require a security key for incoming measurements, it
      is specified with the <em>api_key</em> qualifier. Keys are case sensitive and specific for a given user with the measurements permission enabled.</td>
    </tr>
    <tr>
      <td>test</td>
      <td>Yes</td>
      <td>Add the <em>test</em> qualifier to signify that the measurements are to be marked as test
      values. Test measurements may be easily deleted using the Portal interface.</td>
    </tr>
  </tbody>
</table>


#### Programming Examples

<div id="tabs">
  <ul>
    <li><a href="#tabs-Browser">Browser and Sh</a></li> <!-- names on the tabs -->
    <li><a href="#tabs-Python" >Python</a></li>
    <li><a href="#tabs-C">C</a></li>
  </ul>
  <div id="tabs-Browser"> <!-- content under tab -->
  <div id="browser" class="tab-pane active">
  Data can be submitted to a portal just by typing the URL into the address bar of a browser. It's unlikely that you would use this method for any serious data collection!
  <!-- Add picture here -->
  {% highlight sh %}
  wget http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&email=[USER_EMAIL]&api_key=[API_KEY]

  curl http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&email=[USER_EMAIL]&api_key=[API_KEY]
  {% endhighlight %}

  The <i>wget</i> and <i>curl</i> commands, available in Linux and OSX, can accomplish the same thing from a console.

  </div>
  </div>

  <div id="tabs-Python"> <!-- content under tab -->
  <div id="python" class="tab-pane active">
  {% highlight python %}
  #!/usr/bin/python

  #Put a collection of measurements into the portal
  import requests
  url = 'http://my-chords-portal.com/measurements/url_create?instrument_id=3&t=27.1&rh=55&p=983.1&ws=4.1&wd=213.5&email=[USER_EMAIL]&api_key=[API_KEY]'
  response = requests.get(url=url)
  print response
  ...
  <Response [200]>
  {% endhighlight %}
  </div>
  </div>

  <div id="tabs-C"> <!-- content under tab -->
  <div id="c" class="tab-pane active">

  This example uses the <a href="https://curl.haxx.se/libcurl/c/libcurl.html">libCurl</a> library in a C program to send a measurement URL to a portal.

  {% highlight c %}
  #include <stdio.h>
  #include <curl/curl.h>

  int main(void)
  {
    CURL *curl;
    CURLcode res;

    curl = curl_easy_init();
    if(curl) {
      char* url = "http://chords.dyndns.org/measurements/url_create?instrument_id=25&wdir=121&wspd=21.4&wmax=25.3&tdry=14.3&rh=55&pres=985.3&raintot=0&batv=12.4&at=2015-08-20T19:50:28&email=[USER_EMAIL]&api_key=[API_KEY]";
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
</div>
<script>
$("#tabs").tabs();
</script>

#### Data Out
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

#### Programming Examples




## Particle
How to create a JSON string using Particle

1. In the beginning of your program add the line: ``#define ARDUINOJSON_ENABLE_ARDUINO_STRING 1``
2. Add the library ArduinoJSON ``#include <ArduinoJson.h>``
3. In Loop initialize the JSON, Add variables to the JSON, Publish the JSON as a string

<font color="red">Note:</font> the items that say ``leaf.<something>`` are pulling data from sensors.

```java
DynamicJsonBuffer jBuffer; 
//create a new JSON object to send the sensor data
JsonObject& jsondata = jBuffer.createObject();
 
//Pull Sensor data to variables
float temp = leaf.bme_temp();
float rh_humid = leaf.bme_rh();
float pressure = leaf.bme_p();
 
//JSON string creation
jsondata["bme_temp"] = temp;
jsondata["bme_rh"] = rh_humid;
jsondata["bme_pressure"] = pressure;
 
// Created a new variable named data that is of type string which is needed for particle publish
String data;
jsondata.printTo(data);
Particle.publish("Data",data);
```

For this next step make sure you have the following from your CHORDS portal

**instrument id number**  
**API Key** (Under users)  
**URL** (selecting “Data URLs” and then everything up to the “?”)  

- Log into your [Particle Cloud Console](https://login.particle.io/login?redirect=https://console.particle.io/devices)
- On the left hand side select **“Integrations”** then **“New Integration”**
- Click **"Webhook"**
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Webhook.png"><!--Using liquid to set path for images.-->
- For **event name** type in the name of the Particle Publish event Title (eg. if your code has Particle.publish(“Full Data”, datum); then the event name would be “Data”)
- For the **URL** paste in the URL from “DataURLs” found in CHORDS up to and including the “?”
- For **Request Type** select **"GET"**
- For **Device**, select the appropriate device or leave it as any depending on the project
- Click **"Advanced Settings"**
- Under **"Form Fields"** select **"Custom"**
- In the first two fields type **“instrument_id”** and the number of your instrument id from CHORDS
- Click **"Add Row"**
- In the rows first field type the **“short_name”** from your CHORDS and in the second field enter the **“JSON Key Name”** within a set of two braces (eg. {{short_name}} )  
Chords Short Name
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ChordsVariables.png"><!--Using liquid to set path for images.-->
JSON Key Name
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/JSONKeyName.png"><!--Using liquid to set path for images.-->
<font color="red">Note:</font>short_name from CHORDS and the JSON key name should MATCH. 
- Continue to add rows for all of your variables
- Click **“Create Webhook”**
<p class="notice--primary">Do not Particle.publish data faster than 1 per second or Particle will complain and or limit your ability to stream data (you can insert a “delay(1000);” in your code after a Particle.publish to prevent this issue)</p>

----------------------------------------------------------------------------------------------------------------------------------------------------

## Retrieving Data 

### Download Data

To download data first go to the Data tab in your CHORDS portal. From here you can download data 4 different ways.

1. You can download data within a determined date range.
2. You can download data by selecting specific instruments and then clicking "Download GeoJSON"
3. You can download all of your data by clicking "Select All" and then clicking "Download GeoJSON"
4. You can select "Data URLs" then select the generated url. Combine this with custom code to continue to pull specific data types.

### Grafana
[Grafana](https://grafana.com) is an open-source visualization system that allows you to create powerful data dashboards, right from the browser. The dashboards are very responsive because they fetch data directly from the CHORDS database. The extensive [Grafana documentation](http://docs.grafana.org) explains how to unleash the full capability of the system.

However, the following tutorial explains quickly how to configure Grafana to interact with CHORDS, and how to create a simple dashboard.

**Note: You should have the portal configured with at least one site/instrument/variable before trying to create a dashboard. If there is no data in the portal, you can create some test data using the simulation function.**

Extra credit: once you have been able to make a simple Grafana graph, see this [tutorial](http://docs.grafana.org/features/datasources/influxdb/) for indepth instructions on database access and calculations.

1. **Open Grafana**
  The visualization link will open a new browser window which provides access to the Grafana time-series visualization system.
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_011.png"><!--Using liquid to set path for images.-->

2. **Login**
  - Sign in to Grafana
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_010.png"><!--Using liquid to set path for images.-->
  - Once you've signed in you will be required to change your password.
  - If you need to change your password again or edit permissions go through Admin->Profile:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_020.png"><!--Using liquid to set path for images.-->

3. **Add a new panel to a dashboard**
  - Your grafana is already set up with a dashport but you can set up different panels to suit your needs.
  - Click on the "add a new panel" button in the upper middle part of the screen. 
  - Select your desired panel

4. **Connect data to new panel**
  - Click on the title of the new panel and select "edit"
  - Fill out the content
    **NOTE:**The variable number will relate to the instrument_id **NOT** sensor_id (var = instrument_id)
    <!--add picture here--> 
    “autogen” “tsdata” “var” “(variable number)”
    “field(value)” “mean()”
    “time($_interval)” “fill(null)”
    “(enter legend)”


