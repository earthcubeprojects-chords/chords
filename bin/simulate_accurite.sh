#!/bin/sh

my_dir=`dirname $0`
$my_dir/simulate_instrument.rb \
-c localhost:3000 \
-i 36 \
-s 2 \
-v v1:20:10  \
-v v2:50:20  \
-v v3:10:2   \
-v v4:180:30 \
-v v5:762:10 \
-v v6:10:0.5 \
-v v7:200:4  \
-v v8:20:2 

