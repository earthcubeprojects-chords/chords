#!/bin/sh

my_dir=`dirname $0`
$my_dir/simulate_instrument.rb \
-c localhost:3000 \
-i 37 \
-s 10 \
-v t:20:10  \
-v h:50:20  \
-v ws:10:2   \
-v wd:180:30 \
-v p:762:10

