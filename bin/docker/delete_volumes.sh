#!/bin/sh

# *********************************************
# WARNING: This script removes all docker volumes!
# *********************************************

docker volume rm $(docker volume ls -q)
