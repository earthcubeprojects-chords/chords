#!/bin/sh

my_dir=`dirname $0`
$my_dir/fake_sensor.rb localhost:3000 1 temperature 15 C 1
