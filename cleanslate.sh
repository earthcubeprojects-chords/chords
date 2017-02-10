#!/bin/sh

docker stop $(docker ps -q)
docker rm $(docker ps -qa)

docker rmi $(docker images -q)
docker rmi $(docker images -q)


docker images






# docker run -i -t 66dc510059c7 /bin/bash