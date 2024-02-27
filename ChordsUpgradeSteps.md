# CHORDS Restoring/Upgrading


*Everything is done as root.*

*The following assumes that you have docker installed and that the service is running.*

## Backups

It's ***critical*** that backups be made so that if something goes sideways
you will be able to recover. Since the CHORDS system will be down during
the upgrade, try to make the backups shortly before doing the upgrade, to 
minimize data loss.

It's recommended that you make two backups:

  - A tar file made with `python3 chords_control --backup`. Copy this to
    another machine.
  - A snapshot of the AWS VM instance. This will be easiest to use for
    recovery.

## Restoring versus upgrading

You may want to either *restore* a CHORDS instance, *upgrade* a CHORDS instance,
or both. It depends upon what your goal is.

From above, you will already have made a CHORDS backup file. This contains
the databases that contain timeseries data and grafana configurations.

    ***CHORDS backup files are tied directly to the version of CHORDS that
       was running when it was created***

Restoring CHORDS involves loading the databases into a running CHORDS instance.
Thus, to start a restore, you must have a CHORDS instance of the same version as
the backup was created from.

For upgrading CHORDS to a new version, you can just upgrade a running instance to
the next version. *Note that you can't downgrade to a previous version*.

For upgrade testing against your current data and grafana configurations,
it's useful to combine these steps:

  1. Create a new throw-away (empty) CHORDS instance of the
     same version as your backup.
  2. Restore the CHORDS backup.
  3. Upgrade CHORDS to the next version.

Once you have tested the new, upgraded instance, you can throw it away
and just upgrade the production instance.

## Creating a new CHORDS instance 

This procdure is almost exactly as that found in the CHORDS install
[instructions](https://earthcubeprojects-chords.github.io/chords-docs/gettingstarted/os/).  

```sh
mkdir -p chords-test
cd chords-test

# Install python sh module:
pip3 install sh==1.14.3  # MUST use this version of sh

# Fetch the control script:
curl -O -k https://raw.githubusercontent.com/earthcubeprojects-chords/chords/master/chords_control

# Renew the control script. Choose the one that matches the chords
# backup file version.
python3 chords_control --renew

# Initial installation:
python3 chords_control --config
python3 chords_control --update

# Run  the empty CHORDS (verify with web browser):
python3 chords_control --run

# Restore the backup
# (Answer Y to restore the configuration files):
python3 chords_control --restore <CHORDS backup file>

# Restart:
python3 chords_control --stop
python3 chords_control --run

# Verify using the browser
```

## Upgrading a CHORDS instance

You can upgrade a running CHORDS instance to the *next* release version. All you
are doing is upgrading the running software. The existing databases are used as-is, and will be
upgraded when the new software runs.

You will do this either:
  - after the [previous procedure](#creating-a-new-chords-instance), if you are testing an upgrade
    against an existing CHORDS backup. 
  - or starting here if you are ready to upgrade a running production instance. 

Once again, be sure to make backups shortly before upgrading a
production CHORDS instance.

```sh
# Stop CHORDS
python3 chords_control --stop

# Update the control script. Select the new release (e.g Release-1.1.0-rc5.
python3 chords_control --renew

# Reconfgure. Select the new release (e.g Release-1.1.0-rc5)
python3 chords_control --config

python3 chords_control --run
```

Now use your browser to verify operation.

At this stage, why not go ahead and make a fresh backup:
```sh
python3 chords_control --backup
```

## Grafana gotchas

Grafana v10 has a huge number of changes and improvements. Have fun 
learning how to use them.

### Influxdb authorization

If grafana has been upgraded, it's possible that permissions for accessing the
Influxdb database aren't set. All of the panels will have an alert:    
    *Status: 500. Message: InfluxDB returned error: authorization failed*

Fix this as follows:
  - Look in the *.env* file, and find the value of *CHORDS_ADMIN_PW*.
  - log in as *admin*
  - Under the left dropdown menu, select Connections->Data sources
  - Select the CHORDS data source
  - Enable *Auth: Basic auth*.
  - User and Password boxes will appear. Set them to *admin* and the value of *CHORDS_ADMIN_PW*, respectively.
  - Mash the *Save & Test* button.

### Wind direction gauges

The upgrade to Grafana 10 caused the wind direction gauges to be misconfigured. You
will need to adjust the full scale limits, and perhaps other parameters.

### Wind Rose

CHORDS 1.1.0-rc5 automatically includes the Operato Wind Rose. It's a little tricky to configure:

  - Set up two queries (A/B). 
  - For the A query:
    - Select the wind speed variable in query. Grafana didn't want to use the 
      id that I entered, so you will probably have to directly edit the query string 
      to get this specified correctly.
    - Set the *Alias_by* to *wind_speed*.
  - For the B query:
     - Select the wind direction variable in query. Grafana didn't want to use the 
      id that I entered, so you will probably have to directly edit the query string 
      to get this specified correctly.
    - Set the *Alias_by* to *wind_direction*.
  - Add a data transformation, to aggregate the two fields:
    - Select the *Transform data* tab.
    - Add a transformation.
    - Select *Concatenate fields*.
    - Leave *Copy franme name to field name*.
  - If nothing show up in the wind rose, try expanding
    the time range. You can also see what data comes back from Influxdb
    by using the Query Inspector.

   
