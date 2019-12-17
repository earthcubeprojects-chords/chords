# Changing the Test Flag in CHORDS Influxdb

The ability to download data which were marked as 'test'
disappeared from the CHORDS app somewhere along the
way. It turns out that there are situations where
users need access to the values. For instance, the IS-GEO
Temple PAWS instrument was deployed with 'test=true',
and it is not possible now to change the instrument software.

The following procedure allows these data to be accessed,
in a somewhat roundabout manner, by changing the test
flags in the database from 'true' to 'false'.

This could be done on the running CHORDS container, but for
safety's sake, it was done on an offline container into which
a CHORDS backup set was loaded.

## Procedure

### Create a Standalone CHORDS Instance

1. Log into the source portal, and use ``chords_control --backup``
   to create a backup.
2. Create a new local CHORDS instance, using the same
   release as the source portal.
3. Load the backup into new portal using ``chords_control --restore``, and
   then stop and restart the portal.

### Modify the Influxdb database

_The following are all done from within the chords_influxdb docker container._

Use ``docker exec -it chords_influxdb /bin/bash`` to enter the container.

The broad steps are:

1. Dump the database to a line protocol file.
1. Pull out all of the records with test=true.
1. Change true to false.
1. Import the changed measurements back into influx.
   This will create duplicate measurements, but with "test=false".
1. Drop all series where test = true.

## Install Nano

```sh
apt-get update
apt-get install nano
```

## Get Statistics

```sh  
influx -username=admin -password=<influxdb_pw> -database=chords_ts_production
> select count(*) from "tsdata"
name: tsdata
time count_value
---- -----------
0    2895848
> select count(*) from "tsdata" where "test”='false'
name: tsdata
time count_value
---- -----------
0    1137913
> select count(*) from "tsdata" where "test"='true'
name: tsdata
time count_value
---- -----------
0    1757935
>quit
```
 ### Export the Database

```sh
influx_inspect export -datadir /var/lib/influxdb/data/ -waldir /var/lib/influxdb/wal/ -out ./influxdb.txt
```

### Change the Test Flag

```sh 
grep tsdata influxdb.txt | grep "test=true" > influx_true.txt
sed -e "s/true/false/" influx_true.txt > influx_false.txt

# Set the timestamps to ms precision
sed -e "s/000000$//" influx_false.txt > influx_false_ms.txt
```

### Add Metadata
Use nano to add the following to the head of
_influx_false_ms.txt_:

```sh
# DML
# CONTEXT-DATABASE: chords_ts_production
```

### Import the Modified Measurements

```sh
influx -username=admin -password=<influxdb_pw> -import -path=influx_false_ms.txt -precision=ms
```

### Drop Old Measurements Containing test=true.

```sh
influx -username=admin -password=<influxdb_pw> -database=chords_ts_production

# Check statistics
> select count(*) from "tsdata"
name: tsdata
time count_value
---- -----------
0    4653783
> select count(*) from "tsdata" where "test"='false'
name: tsdata
time count_value
---- -----------
0    2895848
> select count(*) from "tsdata" where "test"='true'
name: tsdata
time count_value
---- -----------
0    1757935

# Drop duplicate measurements
> drop series from "tsdata" where "test"='true'

# Check statistics
> select count(*) from "tsdata"
name: tsdata
time count_value
---- -----------
0    2895848
> select count(*) from "tsdata" where "test"='false'
name: tsdata
time count_value
---- -----------
0    2895848
> drop series from "tsdata" where "test"='true'
> select count(*) from "tsdata" where "test"='true'
```
## Fine

All test flags have been changed to "false".

You will now be able to use the CHORDS data page (http://localhost/data)
to download the data.

Note that CHORDS will still report the same count for test values, because this is a cached value which did not get updated when the flags were changed.
