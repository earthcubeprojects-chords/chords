---
layout: post
title: Docker Advances
---

The [Docker](https://www.docker.com/) version 
of CHORDS now has a persistent database. 

This means that you can start and stop your docker
engine, your CHORDS docker containers, or restart the server, and
the database will survive. It's also very easy to update
to new releases of CHORDS without loosing any data.

[Instructions](https://github.com/NCAR/chords_portal/wiki/Docker-for-CHORDS)
for deploying CHORDS with Docker have been updated.

The Docker version of CHORDS is also now being tested on Amazon Web Services. 
When that is finally rolled out, it will be even a little simpler to spin up a CHORDS
server on Amazon.
