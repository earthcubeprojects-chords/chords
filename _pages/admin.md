---
layout: single
title: Admin
permalink: /admin/
toc: true
toc_sticky: true
toc_label: "Table of Contents"
toc_icon: "cog"
---

## Site Configuration
To configure the site you either have to have Site Configuration or Admin privileges. Configuration is used for managing many (but not all) of the portal characteristics. Sites, instruments, and variables are configured on their own specific pages.

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
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Configure.png">

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
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ConfigureFields.png">

3. Select Metadata Ontology Vocabularies.
4. Enter CUAHSI Data Services, if desired.
5. Fill out contact information.
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ConfigureContact.png">
6. Press Save.
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/ConfigureSave.png">

### Sites

Create a new site by clicking on Sites in the middle left part of the menu.

Click the **Add a New Site** button

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Site.png">

Fill out the empty fields and click **Create Site Instruments**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/SiteFields.png">

Click on the **Instruments** button in the middle left part of the screen

Click **New Instrument**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Instruments.png">

Fill out the blank spaces and click **Create Instrument**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/InstrumentFields.png">

Definitions
Name: Name you gave the instrument

Sensor_Id: ID for a specific sensor. This takes priority over Instrument_ID and creates a unique key. This allows the sensor to be moved from one instrument to another if need be and still retain the same URL format for uploading data. 

Topic Category: Pull down menu of categories and instruments/

Description: (Add additional information you feel necessary here. Like location, website, or purpose.)

Site: Place instrument is located at.

Display Points: How many points are shown on the graph.

Plot offset: Time the plot for display.

Sample Rate: How often you are sampling data, in seconds (fastest is 1 second).

### Variables

Click on your Instrument

Scroll down and click on **Add New Variable**

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Variables.png">

Change the *short name*, *name*, *units*, *the minimum and maximum for plotting*, *the measured property*, *and general measurement category* to match what your Instrument will be measuring.

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/VariableFields.png">

### Metadata
There are two key places you will want to make sure to include a little extra metadata (description of data). 

First, your measured properties and units are part of the metadata, but don’t just call them T or I. One letter doesn’t count for metadata as it’s needed to describe what the data is showing. So give it a more descriptive name (temp, WaterPr). Your data users will appreciate this as metadata is downloaded with your data. 

Second, under your configuration page there is a section for entering JSON-LD metadata. Metadata from your entries create a JSON-LD record that is encapsulated within your Portal instance. These records allow Google (through its [Data Set Search tool](https://toolbox.google.com/datasetsearch)) and other harvesters to discover the existence of your server. This increases the visibility of your data on the web.

### Email 
1. To change an email address simply click on **“Users”** and then click **“Edit”**  

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/Email.png">  

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/EmailUser.png">

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/EmailEdit.png">

2. Type email into the Email Box and click **“Update User”**
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/EmailUpdate.png">


## User Management
To change a User’s information or permissions simply click on **“Users”** and then click **“Edit”**.

<font color="red">Note:</font> if you’re going to update a user make SURE to uncheck the “guest” box before saving your changes. If you don’t “guest” will uncheck all your previous updates and the user will have NO permissions. 

When you are done click **“Update User”**
<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/UserManagement.png">

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
- View Instruments

**Measurement Creator:** Behold! The power of creation! This option let’s Registered Users view and create instruments and variables.

Measurement Creator Can
- Create instruments
- Create test measurements


## Data Backup

There are many ways to backup your data and configuration on your CHORDS portal. First you should note that when you run ``python chords_control --config`` a backup copy of your configuration files is created.
You can also manually back up your portal by saving your configuration and database once everything is set up.  

<img  class="img-responsive" src="{{ site.baseurl }}/assets/images/DataBackup.png">


To save Configuration:
1. Go to Configuration tab
2. Click on **Export Configuration**  

To save Influxdb data:
1. Go to Configuration tab
2. Click on either **Export Influxdb data**

You can also upload previous information from an old portal to a new one by using the **Import** buttons located at the top of the configuration page.
