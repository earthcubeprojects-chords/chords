#!/bin/bash

# Get the CHORDS rails application server running.
#
# Set RAILS_ENV to development or production. If not set,
# it will default to production.
#
# Set CHORDS_ADMIN_PW to the database password.
#
# If RAILS_ENV=production, SECRET_KEY_BASE must be set.
#
# Many environment variables will be used by the CHORDS Rails app
# to show system characteristics (e.g O/S type, source code 
# hash tag, etc.)

# default to production mode
if [ -z "$RAILS_ENV" ]; then
  export RAILS_ENV="production"
fi

# A database password is required.
if [ -z "$CHORDS_ADMIN_PW" ]; then
  export CHORDS_ADMIN_PW="chords_ec_demo"
fi

# The secret key base is required in production mode
if [ $RAILS_ENV == "production" ]; then
  if [ -z "$SECRET_KEY_BASE" ]; then
    export SECRET_KEY_BASE="aaaaaaaaaaa"
  fi
fi

mysql_host="mysql"
# The mysql seeded flag is saved in the directory containing the mysql database.
mysql_seeded_flag="/var/lib/mysql/CHORDS_SEEDED_$RAILS_ENV"

influxdb_host="influxdb"
influxdb_dbname="chords_ts_$RAILS_ENV"
influxdb_admin_user="admin"
influxdb_admin_pw=$CHORDS_ADMIN_PW
influxdb_guest_user="guest"
influxdb_guest_pw=$CHORDS_GUEST_PW
influxdb_retention=$DB_RETENTION

# A script that sets useful environment variables. It in turn
# is created by the create_chords_env_script.sh.
chords_env="./chords_env.sh"

# (Re)start nginx
service nginx restart

# Make sure that the log directory exists
mkdir -p log

# Source the build environment script, if it exists
if [ -e $chords_env ]
then
  . $chords_env
fi
echo "echo CHORDS environment settings:"               
env

# Set some other interesting environment variables.
export CHORDS_KERNEL_NAME=`uname --kernel-name`
export CHORDS_NODENAME=`uname --nodename`
export CHORDS_KERNEL_RELEASE=`uname --kernel-release`
export CHORDS_KERNEL_VERSION=`uname --kernel-version`
export CHORDS_MACHINE=`uname --machine`
export CHORDS_PROCESSOR=`uname --processor`
export CHORDS_HARDWARE_PLATFORM=`uname --hardware-platform`
export CHORDS_OPERATING_SYSTEM=`uname --operating-system`
export CHORDS_RELEASE=$DOCKER_TAG

# Number of Unicorn workers
if [ -z "$WORKERS" ]; then
  export WORKERS=4
fi
# See if there is an existing mysql database
if [ ! -e $mysql_seeded_flag ] 
then
  echo "**** $mysql_seeded_flag not found. We will attempt to create the database."

  for count in {1..60}; do
    echo -n "..$count"
    mysql -h $mysql_host -e "show databases;" >& /dev/null
    if [ $? -eq 0 ]; then
      echo
      break
    fi
    
    if [ $count -eq 60 ]; then
      echo
      echo "Could not contact the database server $mysql_host, aborting CHORDS app startup."
      exit 1
    fi
    
    sleep 1
  done

  echo "Granting mysql permissions."
  bundle exec mysql -h mysql -e "GRANT ALL ON *.* TO 'chords_demo_user';"

  echo "Creating rails database."
  bundle exec rake db:create
else
  echo "**** $mysql_seeded_flag was found. Database will not be created."
fi

echo "Migrating rails database."
bundle exec rake db:migrate

if [ !  -e $mysql_seeded_flag ]; then
  echo "**** $mysql_seeded_flag not found. Seeding rails database."
  bundle exec rake db:seed
else
  echo "**** $mysql_seeded_flag was found. Database will not be seeded."
fi

# poplate empty ontologies 
# this is only relevant to existing portals that have been upgraded
bundle exec rake db:populate_ontologies

# Database ready. Set the SEEDED flag.
touch $mysql_seeded_flag

set -x
# Create the influxdb admin account, used for database writes etc.
curl -s http://$influxdb_host:8086/query --data-urlencode "q=create user $influxdb_admin_user with password '$influxdb_admin_pw' with all privileges"

# Make sure that the influxdb database exists. 
curl -s http://$influxdb_host:8086/query -u $influxdb_admin_user:$influxdb_admin_pw --data-urlencode "q=create database $influxdb_dbname"

# Set the retention policy
curl -s http://$influxdb_host:8086/query -u $influxdb_admin_user:$influxdb_admin_pw --data-urlencode "q=alter retention policy autogen on $influxdb_dbname duration $influxdb_retention"

# Create the influxdb guest account, used for anonymous reads.
curl -s http://$influxdb_host:8086/query -u $influxdb_admin_user:$influxdb_admin_pw --data-urlencode "q=create user $influxdb_guest_user with password '$influxdb_guest_pw'"
curl -s http://$influxdb_host:8086/query -u $influxdb_admin_user:$influxdb_admin_pw --data-urlencode "q=grant read on $influxdb_dbname to $influxdb_guest_user"
set +x

# start cron
touch /var/log/whenever.log
touch /var/log/cron.log
whenever -w
service cron restart

echo "**** Starting web server."
mkdir -p tmp/pids/
rm -f tmp/pids/unicorn.pid
unicorn -p 8080 -c ./config/unicorn.rb -E $RAILS_ENV

