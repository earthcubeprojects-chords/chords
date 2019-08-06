# Summary

The [CHORDS website](http://chordsrt.com) is the offical documentation for CHORDS.

There are also condensed instructions for running the
[CHORDS Docker containers](https://github.com/earthcubeprojects-chords/chords/wiki/Running-CHORDS).

The [CHORDS wiki](https://github.com/earthcubeprojects-chords/chords/wiki) has lots of nitty-gritty information.

# What is CHORDS
A testbed for CHORDS developer and user experiences. It will allow us
to explore technical and usabilty aspects of CHORDS. It can be used
to demonstrate CHORDS design and operational concepts.

The goal is to demonstrate that:
* The development and deployment workflow can be rational and organized,
  allowing multiple developers to contribute to a simple, robust and maintainable system.
* The user experience allows novices to deploy a new CHORDS Portal instance with a minimum
  web infrastructure knowledge. This instance allows them to immediately receive and serve real-time
  data from simple instruments.

This project will provide experience in:
* DevOps (in general) for the CHORDS developers.
* Design, provisioning and deployment of the CHORDS "appliance".
* User interface requirements and usability.

The CHORDS Portal web application will provide limited but immediately useful
functionality:
* A home page, with a logo and some areas for project definition
  and customization.
* A query that can receive a tupple of data, and ingest it into the database.
* A query that can return data from the database.
* A webpage that can navigate and show data in a tabular form, and perhaps
  deliver a CSV file.
* A webpage that provides a URL builder, than can be used immediately, and used
  as a template for client applications.
* A webpage which provides a summary of the current data holdings and
  ingest activity.
  
# Imaging Feature 
The imaging feature within this application utilizes Leaflet JS and Leaflet.heat to create interactive heat maps using JSON data created from NetCDF files. It also has an image overlay feature in Leaflet JS that allows visualization of data on an interactive map using PNG images of plotted NetCDF data.

* Ruby version: 2.6.0

* Rails version: 5.2.3

* Configured to interact with PostGRESQL

* Utilizes Active Storage to help with uploading and downloading JSON and image files

* Map feature run through Leaflet JS and Leaflet.Heat plugin* [See Note below]

Tutorials in https://leanpub.com/leaflet-tips-and-tricks/read were useful as a starting point for building maps

# In order to get started: 

* Git clone project into the directory you would like 
```
git clone git@github.com:abisuresh/databaseVersion_imageApp.git
```

* Make sure you have rails installed on your system 

* Start the rails server by typing the following into the command line from the root of the application: rails server 

* In order to upload a JSON file and see the resulting map (with data plotted in heatmap version): 
    -> Navigate to localhost:3000/radar_data 
    
* In order to upload a NetCDF file and see the resulting map (with data plotted using PNG images) :
    -> Navigate to localhost:3000/input_data 

# Running with a Docker-based database

```
docker run --name postgres -p 5432:5432 -d postgres
RAILS_ENV=development rake db:create
RAILS_ENV=development rails db:migrate RAILS_ENV=development
RAILS_ENV=development rails s -b localhost
```
# Build using docker-compose

* Git clone project into the directory you would like 
```
git clone git@github.com:abisuresh/databaseVersion_imageApp.git
```

* Install docker, docker LFS, and docker-compose

* build the docker image, create the database, and run all migrations
```
docker-compose build
docker-compose run web rake db:create
docker-compose run web rake db:migrate
```

* Start the docker containers
```
docker-compose up -d
```

* Stop the docker containers
```
docker-compose down
```

* In order to upload a JSON file and see the resulting map (with data plotted in heatmap version): 
    -> Navigate to localhost/radar_data 
    
* In order to upload a NetCDF file and see the resulting map (with data plotted using PNG images) :
    -> Navigate to localhost/input_data 


# Note: The Leaflet.heat Plugin is licensed under a permissive license that allows both private and commercial use and distribution with or without modification provided the following statement is provided along with use:  

Copyright (c) 2014, Vladimir Agafonkin
All rights reserved.
https://github.com/Leaflet/Leaflet.heat

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# This project is sponsored by funding from the National Science Foundation under ICER awards 1639750, 1639640, 1639570, 1639554 and 1639720.
