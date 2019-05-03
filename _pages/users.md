---
layout: single
title: Users
header:
  overlay_color: "#11999e"
  overlay_filter: "1.0"
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

You guessed it. This option lets Users view and download data from instruments.

A Data Downloader can:
- Download data
- View Instruments, (only if combined with Registered user)

1. Log into chords
2. Click on **“Data”** on the left side of your screen 
3. Select the dates that you want to download data from
4. Select the instruments you want to download data from OR click **“Select All”**

5. Click **“Download GeoJSON”**


### Measurement Creator

Measurement Creator can:
- Create test data
- Create test measurements

As a measurement creator it is recommended that you keep this account separate from other accounts that are used for data downloading or just as a registered user. Doing so prevents security issues in the future. Each Measurement user has their own API key to send measurements. 

To find your api key: 
1. Log into chords with your measurement account
2. Click on **“Users”** on the upper right corner of the screen
3. Copy the randomly generated key under API key.

<font color="red">Note: </font>You should only have ONE API key per instrument. 






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

{% include video id="B02M7pXEybM" provider="youtube" %}


[Grafana](https://grafana.com) is an open-source visualization system that allows you to create powerful data dashboards, right from the browser. The dashboards are very responsive because they fetch data directly from the CHORDS database. The extensive [Grafana documentation](http://docs.grafana.org) explains how to unleash the full capability of the system.

However, the following tutorial explains quickly how to configure Grafana to interact with CHORDS, and how to create a simple dashboard.

**Note: You should have the portal configured with at least one site/instrument/variable before trying to create a dashboard. If there is no data in the portal, you can create some test data using the simulation function.**

Extra credit: once you have been able to make a simple Grafana graph, see this [tutorial](http://docs.grafana.org/features/datasources/influxdb/) for indepth instructions on database access and calculations.

This is an example of Grafana panel embedding. The iframe element is:
```
<iframe src="http://portal.chordsrt.com:3000/d-solo/000000015/5-ml-sonic?refresh=1m&orgId=1&panelId=1&from=now-1h&to=now" width="800" height="600" frameborder="0"></iframe>
```

<iframe src="http://portal.chordsrt.com:3000/d-solo/000000015/5-ml-sonic?refresh=1m&orgId=1&panelId=1&from=now-1h&to=now" width="600" height="400" frameborder="0"></iframe>

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

**NOTE:**The variable number will relate to the instrument_id **NOT** sensor_id. (var = instrument_id)

  <img  class="img-responsive" src="{{ site.baseurl }}/assets/images/grafsetup_120.png"><!--Using liquid to set path for images.-->
    “autogen” “tsdata” “var” “(variable number)”  
    “field(value)” “mean()”  
    “time($_interval)” “fill(null)”  
    “(enter legend)”


