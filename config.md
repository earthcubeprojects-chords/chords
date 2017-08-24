---
layout: page
title: Portal Configuration
---

# How to Configure your Portal

## Step 1
* Log into your portal using 
`````
User: admin@chordsrt.com
Password: realtimedata
`````

<img class="img-responsive" src="images/Config_Step1.PNG" alt="Step 1 Sign in" />
<br>
<hr>


## Step 2

* Click on the "**Configure**" selection in the upper right part of the screen

<img class="img-responsive" src="images/Config_Step2_pt1.PNG" alt="Step 2 Configure" />

It will take you to a page called <em>Configuration</em>

<img class="img-responsive" src="images/Config_Step2_pt2.PNG" alt="Step 2 Configure Page" />

From here enter the:
  - Project name
  - DOI (optional)
  - Affiliation
  - Page title (e.g. what project you’re working on. Like Orcas, STORM, NCAR Portal, etc.)
  - Domain name: The domain name should either be the fully qualified domain name of the portal (if you have one) or the IP address of the
  server on which the portal is hosted, e.g. from AWS. Make sure to change the default value as archiving will fail if it is not set!
  - Time zone
  - Project Description: A short description of what your project is. This may use HTML Markup, if you haven’t used HTML markup or aren’t sure what it is, go to [this link](http://www.w3schools.com/html/html_intro.asp)
  - Logo File: You may upload a customized logo for your portal here. It will appear in the portal header page.
  - Enter your [Google Maps API Key](https://developers.google.com/maps/documentation/embed/get-api-key)
    **Special note to CUAHSI workshop participants:** You can cut and past this text to use as your Google Maps API Key:
`````
  AIzaSyCaJcuGGmb9pumPJ8tptUobGUMlMWpmSRQ
`````
  - Select security options. For production use we recommend that a key be used for data entry (see example in Step 4).

Once you've entered all of that click **Save**.

If you are planning to archive the data at one of NSF's data archive sites, you can enter the archive-specific settings below. Here we use
the example of settings needed for the [Consortium of Universities for the Advancement of Hydrologic Science, Inc. (CUAHSI)](https://www.cuahsi.org/) archive:

<img class="img-responsive" src="images/Config_Step2_pt3.PNG" alt="Step 2 Archive Configure Page" />

Click **Save**.

<br>
<hr>

## Step 3

**Note**: In the following screens, it may not be obvious that you can click on the areas highlighted in <em>light green</em> to change
the settings there.

* Create a new Site by clicking on the **Sites** selection in the middle left part of the screen and clicking the **Add A New Site**
button.
<img class="img-responsive" src="images/Config_Step3_pt0.PNG" alt="Sites" />

Fill out the highlighted fields to create a new Site:

`````
Name: Name of site
Lat, Lon and Elevation: Physical location of site
Site Type: Select among the terms in the pull-down menu
CUAHSI Site Code: Leave this field blank as it will be auto-configured
`````

* Click on the **Instruments** button in the middle left part of the screen.
<img class="img-responsive" src="images/Config_Step3_pt1.PNG" alt="Instruments" />

* Click on **New Instrument**, it will open up a new page where you can create an instrument.

<br>
<hr>
<img class="img-responsive" src="images/Config_Step3_pt2.PNG" alt="New Instrument" />

* Enter your information here and then click "**Create Instrument**"

**Definitions:**
`````
Name: The name you gave the instrument
Topic category: Pull down menu of categories of instruments
Description: (Add additional information you feel necessary here. Like location, website, or purpose.)
Site: Site that the instrument resides at
`````

<img class="img-responsive" src="images/Config_Example 1.PNG" alt="Description" />

`````
Display Points: How many points are shown on the graph
Plot offset: How often the plot window should span
Sample Rate: How often you are sampling data, in seconds (fastest is 1 second)
`````
<br>
<hr>
<img class="img-responsive" src="images/Config_Step3_pt3.PNG" alt="Description" />

<br>
<hr>

* Click on **Add a New Variable**

* Change the <em>short name, name, units, the minimum and maximum for plotting, the measured property and general measurement category </em> to match what your Instrument will be measuring.

**Note:** This will be more fully described later, but the short name you choose will be used in the URLs for entering data points. Make
sure that they make sense for later use.
(e.g. use a short name like **temp** for temperature):
http://localhost:8080/measurements/url_create?instrument_id=2&temp=202.0&bv=209.5&uv=218.3&aq=231.9&at=2017-02-15T23:16:21.988Z&key=key&test)

<br>
<hr>

## Step 4
 Now you’ve gotten logged into your portal and set up your instrument. Click on the **Data URLs** link in the _Data Access and Downloads_
 box. 
<img class="img-responsive" src="images/Config_Step4.PNG" alt="Data In" />

<img class="img-responsive" src="images/Config_Step4.5.PNG" alt="Data URLs page" />

This page describes how to put data into your portal and get data out via simple URLs. A data point can be submitted to a portal by just
copying and pasting the URL into the address bar of a browser, using the short variable names you have set up add the key if you specified
one. Thus, a sample URL to put one item of test data into your portal, using the configuration specified in these instrcutions, could be:

`````
http://portal.chordsrt.com/measurements/url_create?instrument_id=4&depth=202.0&bv=209.5&at=2017-02-
15T23:16:21Z&key=chordskeyforvalues&test
`````

By entering this URL in your browser, one point of test data is entered into your portal. The URL specifies that the data were collected
on February 15th, 2017 at 23:16:21 GMT and that the depth value recorded was 202.0 and the battery voltage was 209.5

This method, however, isn’t meant for serious data submission as it would be more likely that you would write a script to automate the data entry via URLs rather than typing them in manually. If you’d like more information on this, the [Data In tab from chordsrt.com](http://ncar.github.io/chords/datain.html) shows code examples as well.

<br>
<hr>
## Step 5
Now that you’ve learned how to put Data In and Out via web services protocols, how about downloading all data across a block of time?
You can do this from the Portal by clicking on <em>**“Data”**</em>
<img class="img-responsive" src="images/Config_Step5_pt1.PNG" alt="Data out" />

Once there you can choose which instrument you want the data from, the timeframe and in what format. CHORDS offers data in 
* **GeoCSV** (Standardized Comma Separated Value file) 
* **GeoJSON** (Standardized JavaScript Object Notation file)
* **XML** (Extensible Markup Language) 

as options for downloading and viewing the data collected. Once you click on one of these buttons your data will be downloaded into the specified format which can be opened in Excel, Word or Notepad.

<img class="img-responsive" src="images/Config_Step5_pt2.PNG" alt="Data Download" />

If you’d like to see more about this, the [Data out tab from chordsrt.com](http://ncar.github.io/chords/dataout.html) will provide additional information as well as programming examples. 
<br>
<hr>


## Step 6
Now your portal is up and running and you’re ready to add your team in. But how on earth do we do that? 
* First your users will have to create an account of their own. They can do this by clicking on the “<em>**Sign In**</em>” Button at the top right hand corner of your chords site. 

<img class="img-responsive" src="images/Config_Step7_pt1.PNG" alt="Sign in" />

* Then Click on “<em>**Sign up**</em>”


<img class="img-responsive" src="images/Config_Step7_pt2.PNG" alt="Sign up" />

* They will have to enter an email and create a password of their own. Then click “<em>**Sign up**</em>”

<img class="img-responsive" src="images/Config_Step7_pt3.PNG" alt="Sign up" />

* When the user first signs up they won't have any permissions so admins will have to go and grant them special permissions after they’ve created an account. Admins can assign permissions by going to “<em>**Users**</em>”


<img class="img-responsive" src="images/Config_Step7_pt4.PNG" alt="Sign up" />

* From there they can toggle yes or no for whether or not the users can be admins view or load data just by clicking on the yes’s and no’s highlighted in green

<img class="img-responsive" src="images/Config_Step7_pt5.PNG" alt="Users" />
<br>
<hr>
# Geo Button
When you click on the geo button you will see one of two things. 

<img class="img-responsive" src="images/Config_Geo.PNG" alt="Geo Button" />

The first will be a map showing the areas where you have set up the instruments with some distinct geographical pointers.

The second is a satellite image showing a snapshot of the area and where you’ve specified the instruments are. 

<img class="img-responsive" src="images/Config_TZVolcano2.PNG" alt="Geo Button" />

picture courtesy of [Tanzania Volcano Observatory](http://tzvolcano.chordsrt.com/sites/geo)


Next, you can configure CHORDS services, such as [CUAHSI Data Services for hydrology data](https://github.com/NCAR/chords/wiki/CUAHSI-Archive) which will connect your CHORDS data stream to an official archive.

**Note:**  If the map says “Opps!...”, you need to enter a google Maps API key in CHORDS configuration. Google allows up to 25,000 free map accesses per day. You can request a google maps API key if you have a Google account. After you have the key, go to the Configure page and enter it into the “google Maps JavaScript API Key” box.



