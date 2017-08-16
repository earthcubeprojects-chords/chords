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
  - Time zone
  - A short description of what your project is. This may use HTML Markup, if you haven’t used HTML markup or aren’t sure what it is, go to [this link](http://www.w3schools.com/html/html_intro.asp)
  - Select security options 
  
  For Google Maps API Key, you can cut and past this text:
`````
  AIzaSyCaJcuGGmb9pumPJ8tptUobGUMlMWpmSRQ
`````

Once you've entered all of that click **Save**.

If you are planning to archive the data at one of NSF's data archive sites, you can enter the archive-specific settings below. Here we use
the example of settings needed for the [Consortium of Universities for the Advancement of Hydrologic Science, Inc. (CUAHSI)](https://www.cuahsi.org/) archive:

<img class="img-responsive" src="images/Config_Step2_pt3.PNG" alt="Step 2 Archive Configure Page" />

Click **Save**.

<br>
<hr>

## Step 3

* Click on the **instruments** button in the middle left part of the screen.
<img class="img-responsive" src="images/Config_Step3_pt1.PNG" alt="Instruments" />
* Click on "<em>**New Instrument**</em>" it will open up a new page where you can create an instrument.

<br>
<hr>
<img class="img-responsive" src="images/Config_Step3_pt2.PNG" alt="New Instrument" />

* Enter your information here and then click "<em>**Create Instrument**</em>"

**Definitions:**
````
Instrument: (The name you gave the instrument)
Site: (Physical location of the instrument)
Description: (Add additional information you feel necessary here. Like location, website, or purpose.)
````
<img class="img-responsive" src="images/Config_Example 1.PNG" alt="Description" />
````
Data Ingest/fetch: (URLS for collecting data)
Instrument ID: The latest instrument you’ve made (e.g. 16 means this is the 16th instrument I’ve created)
Last Measurement: (Keeps track of how many days ago you last collected data with this instrument, if you haven’t collected any yet it will say “never”)
Measurements: How many measurements you’ve taken
Test Measurements: How many simulated measurements you’ve taken
Display Points: How many points are shown on the graph
Measurement interval (s): How often you are adding data per second. (speed of data collecting. fastest is 1 second)
````
<br>
<hr>
<img class="img-responsive" src="images/Config_Step3_pt3.PNG" alt="Description" />

**Note**: If you click on the areas highlighted in <em>light green</em> you can change the information there.

<br>
<hr>
* Click on <em>**Add a New Variable**</em>
* Change the <em>short name, name, and units </em> to match what your Instrument will be measuring.

**Note:** The short name you choose will be used in the URLs for entering data points. Make sure that they make sense for later use.
(e.g. **temp** for temperature:
http://localhost:8080/measurements/url_create?instrument_id=2&**temp**=202.0&bv=209.5&uv=218.3&aq=231.9&at=2017-02-15T23:16:21.988Z&key=key&test)

<img class="img-responsive" src="images/Config_Step3_pt4.PNG" alt="Shortname" />


<br>
<hr>

## Step 4
 Now you’ve gotten logged into your portal and set up your instrument. You’ll notice that there is a URL that is generated when you created your instrument. 
<img class="img-responsive" src="images/Config_Step4.PNG" alt="Data In" />


Your data can be submitted to a portal by just copying and pasting the URL into the address bar of a browser. This method, however, isn’t meant for serious data collection. It would be more likely that you would write a script to automate the data entry via URLs. If you’d like more information on this the “Data In” tab of http://ncar.github.io/chords/datain.html shows code examples as well.

<br>
<hr>
## Step 5
Now that you’ve learned how to put Data In, how about taking Data Out? You can do this from the Portal by clicking on <em>**“Data”**</em>
<img class="img-responsive" src="images/Config_Step5_pt1.PNG" alt="Data out" />

Once there you can choose which instrument you want the data from and in what format. CHORDS offers data in 
* **CSV** (Comma Separated Variables) 
* **JSON** (JavaScript Object Notation)
* **XML** (Extensible Markup Language) 

as options for downloading and viewing the data collected. Once you click on one of these buttons your data will be downloaded into a format which can be opened in word or notepad.

<img class="img-responsive" src="images/Config_Step5_pt2.PNG" alt="Data Download" />

If you’d like to see more about this, the “Data out” tab from chordsrt.com or http://ncar.github.io/chords/dataout.html will provide additional information as well as programming examples. 
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

<img class="img-responsive" src="images/Config_TZVolcano1.PNG" alt="Geo Button" />
<em>picture courtesy of Tanzania Volcano Observatory [http://tzvolcano.chordsrt.com/sites/geo] (http://tzvolcano.chordsrt.com/sites/geo)</em>

The second is a satellite image showing a snapshot of the area and where you’ve specified the instruments are. 

<img class="img-responsive" src="images/Config_TZVolcano2.PNG" alt="Geo Button" />
<em>picture courtesy of Tanzania Volcano Observatory [http://tzvolcano.chordsrt.com/sites/geo] (http://tzvolcano.chordsrt.com/sites/geo)</em>

**Note:**  If the map says “Opps!...”, you need to enter a google Maps API key in CHORDS configuration. Google allows up to 25,000 free map accesses per day. You can request a google maps API key if you have  Google account. After you have the key, go to the Configure page and enter it into the “google Maps JavaScript API Key” box.



