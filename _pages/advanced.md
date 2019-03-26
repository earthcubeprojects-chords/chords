---
layout: single
title: Advanced
permalink: /advanced/
toc: true
toc_sticky: true
toc_label: "Table of Contents"
toc_icon: "cog"
---

## Chords_Control
Chords_Control is the CHORDS management script. Used to manage the CHORDS portal configuration, running/stopping the portal, and updating the portal software.

 
There are several main ways to use chords_control

``python chords_control --config``
- Lets you configure your CHORDS portal.
  - Set your password
  - Set email for password reset
  - Set guest password
  - Configure portal port

``python chords_control --update``
- Updates your portal's software

``python chords_control --run``
- Starts your CHORDS portal

``python chords_control --stop``
- Stops your CHORDS portal

``python chords_control -t``
- Lets you check your portal's current status

If you have difficulties with your chords) control you can always type ``python chords_control --help``

## Docker

Docker is used as a tool to make it easier to create, deploy and run CHORDS by using containers. Containers let us package CHORDS with all the parts it needs, like libraries and other dependencies, and ship it out in one nice simple package. For more information on Docker check out their [website](https://docs.docker.com/get-started/).

### Docker logs

``docker logs -f chords_app`` command shows information logged by a running chords container.


### Removing old docker images

To remove a specific Image
``docker images -a`` Lists ID’s of images 
``docker rmi Image Image`` Place image ID after “docker rmi” to remove it specifically

 ``docker system prune`` Lets you clean up resources (images, containers, volumes, and networks) that are not associated with the container.


``docker system prune -a`` Lets you remove stopped containers as well as the resources listed above. (Use with CAUTION)

``Docker exec -it (containername) /bin/bash``

### Save disk space

``docker system df`` Shows docker disk usage
``docker system events`` Gets real time events from the server
``docker system info`` Displays system-wide information
``docker system prune`` Removes unused data