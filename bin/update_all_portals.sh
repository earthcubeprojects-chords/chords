#!/bin/sh

# echo "updating portal.chordsrt.com"
# ssh -i $1 ec2-user@portal.chordsrt.com 'cd /home/ec2-user/chords_testbed ; git pull '
# echo ""


echo "updating portal.chordsrt.com"
ssh -i $1 ec2-user@tzvolcano.chordsrt.com 'cd /home/ec2-user/chords_portal ; git pull '
echo ""


echo "all update finished"



 # sudo chown -R ec2-user:ec2-user ./chords_portal