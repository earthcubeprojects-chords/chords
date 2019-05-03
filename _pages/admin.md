---
layout: single
title: Admin
header:
  overlay_color: "#000"
  overlay_filter: "0.5"
permalink: /admin/
toc: true
toc_sticky: true
toc_label: "Table of Contents"
toc_icon: "cog"
#classes: "wide"
---

## Site Configuration
To configure the site you either have to have Site Configuration or Admin privileges. Configuration is used for managing many (but not all) of the portal characteristics. Sites, instruments, and variables are configured on their own specific pages.

<!--TO DO: make new configuration video with sound!-->
### Editing User Permissions

1. To edit users go to the Users tab
2. Click on the email/username of the user you want to edit
3. Click "Edit User"
4. Select the permissions you want for your user
5. Click "Update User"

**Tip for Admins** If you want to check user permissions while using two windows in your browser either make one browser incognito mode or open a new window in another web browser. Otherwise you will mix up the sites cookies and have to clear your browser cache.

### Portal Configuration
Admins can edit the portal configuration as well as users with Site Configuration permission.

1. Click on “Configure” selection in the upper right part of the screen. It will take you to a page called Configuration
You will find buttons that will allow you to 
- Export/Import previous Configuration
- Export/Import previous InfluxDB Data
- Configure JSON-LD Options
- Configure InfluxDB Tags
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Configure.png"> <!--Using liquid to set path for images.-->

2. Fill out the following under Standard Options: 
Project name

DOI (optional)

Affiliation

Page title (e.g. the name of the project you’re working such as “Orcas”, “3D-PAWS”, “STORM”, “NCAR weather stations”, etc.)

Domain name: The domain name should either be the fully qualified domain name of the portal (if you have one) or the IP address of the server on which the portal is hosted, e.g. from AWS. Make sure to change the default value as the archiving function may fail if it is not set!

Data Archive URL: This is the link to the archive of data being ingested by CHORDS. Users will generally archive the data in the portal on regular intervals.

Time Zone

Project Description: A short description of your project. This may use HTML Markup. If you haven’t used HTML markup or aren’t sure what it is, you may see this link.

Logo File: You may upload a customized logo for your portal here. It will appear in the portal header page. 

Max Download Points: Set how many maximum points you want in your data downloading. 

Note: Do NOT make this blank

Select Security options: Default security options enable others to view data. If you don’t want to let guests or others view your data check “Restrict view of data”.
Do NOT modify the Measurement Security Key
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ConfigureFields.png"><!--Using liquid to set path for images.-->

3. Select Metadata Ontology Vocabularies.
4. Enter CUAHSI Data Services, if desired.
5. Fill out contact information.
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ConfigureContact.png"><!--Using liquid to set path for images.-->
6. Press Save.
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ConfigureSave.png"><!--Using liquid to set path for images.-->

### Sites

Create a new site by clicking on Sites in the middle left part of the menu.

Click the **New Site** button

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Site.png"><!--Using liquid to set path for images.-->

Fill out the empty fields

Click **Create Site**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/SiteFields.png"><!--Using liquid to set path for images.-->

### Instruments

Click on the **Instruments** button in the middle left part of the screen

Click **New Instrument**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Instruments.png"><!--Using liquid to set path for images.-->

Fill out the blank spaces and click **Create Instrument**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/InstrumentFields.png"><!--Using liquid to set path for images.-->

Definitions
Name: Name you gave the instrument

Sensor_Id: ID for a specific sensor. This takes priority over Instrument_ID and creates a unique key. This allows the sensor to be moved from one instrument to another if need be and still retain the same URL format for uploading data. 

Topic Category: Pull down menu of categories and instruments

Description: (Add additional information you feel necessary here. Like location, website, or purpose.)

Site: Place instrument is located at.

Display Points: How many points are shown on the graph.

Plot offset: Time the plot for display.

Sample Rate: How often you are sampling data, in seconds (fastest is 1 second). It is also used for visual purposes as this determines when the little circle next to the instrument is green or red. 

### Variables

Click on your Instrument

Scroll down and click on **Add New Variable**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Variables.png"><!--Using liquid to set path for images.-->

Change the *short name*, *name*, *units*, *the minimum and maximum for plotting*, *the measured property*, *and general measurement category* to match what your Instrument will be measuring.

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/VariableFields.png"><!--Using liquid to set path for images.-->

### Metadata
There are two key places you will want to make sure to include a little extra metadata (description of data). 

First, your measured properties and units are part of the metadata, but don’t just call them T or I. One letter doesn’t count for metadata as it’s needed to describe what the data is showing. So give it a more descriptive name (temp, WaterPr). Your data users will appreciate this as metadata is downloaded with your data. 

Second, under your configuration page there is a section for entering JSON-LD metadata. Metadata from your entries create a JSON-LD record that is encapsulated within your Portal instance. These records allow Google (through its [Data Set Search tool](https://toolbox.google.com/datasetsearch)) and other harvesters to discover the existence of your server. This increases the visibility of your data on the web.

### Email
1. To change an email address simply click on **“Users”** and then click **“Edit”**  

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Email.png">  <!--Using liquid to set path for images.-->

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/EmailUser.png"><!--Using liquid to set path for images.-->

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/EmailEdit.png"><!--Using liquid to set path for images.-->

2. Type email into the Email Box and click **“Update User”**
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/EmailUpdate.png"><!--Using liquid to set path for images.-->

### Creating and Sending Data
Admins and Site Configs do not have permission to create test data or send data to CHORDS for security purposes. Any Registered user with Measurement Creator checked can create test data and send data to CHORDS. However Admins will have to give that user an API key. To create an API key for a user: 
* Click **Users**
* Click the Measurement User
* Click **Edit**
* Click **Renew API Key** 

## User Management
To change a User’s information or permissions simply click on **“Users”** and then click **“Edit”**.

<font color="red">Note:</font> if you’re going to update a user make SURE to uncheck the “guest” box before saving your changes. If you don’t “guest” will uncheck all your previous updates and the user will have NO permissions. 

When you are done click **“Update User”**
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/UserManagement.png"><!--Using liquid to set path for images.-->

<font color="red">Note:</font> IF you select Guest in user configuration it will unselect ALL other options. Please make sure to unselect Guest before you save User Permissions.

**Guest:** The Default for any new user except Admins. It has the minimum permissions and users should request that their Admin upgrade them to a Registered user at the least.

A Guest User Can
- Read About page
- View self information


**Registered User:** This option is better than Guest but still limited in use. Combining it with Data Downloader or Measurement Creator will enable extra functionality in CHORDS giving your Registered User’s more POWER.  Just make sure to use your powers for good and not evil, ok?

A Registered User Can
- Read About page and view data
- View Site
- View Instruments
- Can View and edit self information

**Data Downloader:** You guessed it. This option lets Registered Users view and download data from instruments.

A Data Downloader Can
- Download data
- View Instruments, (only if combined with Registered user)

**Measurement Creator:** Behold! The power of creation! This option let’s Registered Users view and create instruments and variables.

Measurement Creator Can
- Create test data
- Create test measurements

**Site Config:** This user is similar to an Admin. They can do everything except editing users and creating test data.

A Site Config Can

- Edit Site Configuration
- Read About page and view data
- View Site
- View Instruments
- Can View and edit self information
- Download data
- View Instruments
- Create Instruments

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



## Data Backup

There are many ways to backup your data and configuration on your CHORDS portal. First you should note that when you run ``python chords_control --config`` a backup copy of your configuration files is created.
You can also manually back up your portal by saving your configuration and database once everything is set up.  

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/DataBackup.png"><!--Using liquid to set path for images.-->


To save Configuration:
1. Go to Configuration tab
2. Click on **Export Configuration**  

To save Influxdb data:
1. Go to Configuration tab
2. Click on either **Export Influxdb data**

You can also upload previous information from an old portal to a new one by using the **Import** buttons located at the top of the configuration page.
