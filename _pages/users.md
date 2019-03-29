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

Users can create, view, and download data from CHORDS. However a person’s access level will determine the functions available. Permissions such as data downloader and measurement creator are enhancements on a registered user, while the guest user is equivalent to not being logged in.

### Guest

The <font color="red">Default </font> for any new user except Administrators. It has the minimum permissions and users should request that their Admin upgrade them to a Registered User.

A Guest User can:
- View About page
- View and edit self information

### Registered User

This option is better than Guest but still limited in use. Combining it with <font color="red"> Data Downloader </font> or <font color="red"> Measurement Creator </font> will enable extra functionality in CHORDS giving you more POWER. Just make sure to use your powers for good and not evil.

A Registered User can:
- View about page
- View Data
- View Site
- View Instruments
- View and edit self information

### Data Downloader

You guessed it. This option lets Registered Users view and download data from instruments.

A Data Downloader can:
- Download Data
- View Instruments

### Measurement Creator

Behold! The power of creation! This option let’s Registered Users view and create instruments and variables.  
this belongs in the paragraph

Measurement Creator:
- Create Instruments
- Create test measurements


## Storing Measurements

### Sending a URL from UNIX
To post data to your chords portal
``curl --data "param1=value1&param2=value2" http://hostname/resource``


### Arduino
### Particle
How to create a JSON string using Particle

1. In the beginning of your program add the line: ``#define ARDUINOJSON_ENABLE_ARDUINO_STRING 1``
2. Add the library ArduinoJSON ``#include <ArduinoJson.h>``
3. In Loop initialize the JSON, Add variables to the JSON, Publish the JSON as a string

<font color="red">Note:</font> the items that say ``leaf.<something>`` are pulling data from sensors.

```c
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
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Webhook.png">
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
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ChordsVariables.png">
JSON Key Name
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/JSONKeyName.png">
<font color="red">Note:</font>short_name from CHORDS and the JSON key name should MATCH. 
- Continue to add rows for all of your variables
- Click **“Create Webhook”**
<p class="notice--primary">Do not Particle.publish data faster than 1 per second or Particle will complain and or limit your ability to stream data (you can insert a “delay(1000);” in your code after a Particle.publish to prevent this issue)</p>

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
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_011.png">
2. **Login**
  - Sign in to Grafana
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_010.png">
3. **Creating a datasource**
  - Add a data source:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_030.png">
  - Configure the data source:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_040.png">
  - When configured correctly, success will be indicated:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_041.png">
  - If something is not configured correctly, you may see a message: **"Unknown error":**
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_042.png">
    - Make changes, and mash **Save & Test** again.

4. **Add a dashboard**
  - Select New dashboard:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_050.png">
  - A new dashboard is created, with an empty panel. Add a graph by pressing Graph:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_051.png">
  - Click in the bar at the top of the graph, to pop up a menu:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_060.png">
  - And select Edit:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_070.png">
  - Configure the panel: 
    Use the General tab to set a title:
    <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_110.png">
    Use the Display tab to change the appearance:
    <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_100.png">
    The variable identifires are obtained from the CHORDS Instruments page: <!--Need to grab a picture from chords for this-->
    <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_120.png">
    Use the Metrics tab to configure the database access. Close when you see plotted data:
    <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_095.png">

5. **Change the admin password**
  - Finally, be sure to change (and remember) the admin password for grafana. This is accessed through Admin->Profile:
  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_020.png">
