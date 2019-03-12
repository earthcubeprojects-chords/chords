---
layout: single
title: CHORDS is being adapted to run under Docker
sidebar:
  title: "Sample Title"
  nav: sidebar-sample
---

We are working on making a CHORDS portal available using [Docker](https://www.docker.com/). 

This means that you will be able to run a CHORDS portal locally, on your own 
Mac, Windows or Linux system. We will also upgrade the CHORDS cloud creation
processs so that the Docker images are used on AWS and other cloud services.

A prototype of the Docker implmentation is already working, so right now you can 
easily install and run CHORDS locally. [Instructions](https://github.com/NCAR/chords_portal/wiki/Docker-for-CHORDS)
are provided on Docker Hub. 

At this time, the CHORDS database is not persistent. If you shut down the CHORDS docker containers,
the database will be lost. Fixing this is one of the first improvements we plan to make.
