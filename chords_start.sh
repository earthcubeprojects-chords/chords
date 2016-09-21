#!/bin/bash

server="mysql"
seeded_flag="/var/lib/mysql/CHORDS_SEEDED"
chords_env="./chords_env.sh"

# Make sure that the log directory exists
mkdir -p log

# Source the build environment script, if it exists
if [ -e $chords_env ]
then
  . $chords_env
  env
fi

# Set some other interesting environment variables
export CHORDS_KERNEL_NAME=`uname --kernel-name`
export CHORDS_NODENAME=`uname --nodename`
export CHORDS_KERNEL_RELEASE=`uname --kernel-release`
export CHORDS_KERNEL_VERSION=`uname --kernel-version`
export CHORDS_MACHINE=`uname --machine`
export CHORDS_PROCESSOR=`uname --processor`
export CHORDS_HARDWARE_PLATFORM=`uname --hardware-platform`
export CHORDS_OPERATING_SYSTEM=`uname --operating-system`

# Number of Unicorn workers
export WORKERS=4

# See if there is an existing database
if [ ! -e $seeded_flag ] 
then
  echo "**** $seeded_flag not found. We will attempt to create the database."

  for count in {1..60}; do
    echo -n "..$count"
    mysql -h $server -e "show databases;" >& /dev/null
    if [ $? -eq 0 ]; then
      echo
      break
    fi
    
    if [ $count -eq 60 ]; then
      echo
      echo "Could not contact the database server $server, aborting CHORDS app startup."
      exit 1
    fi
    
    sleep 1
  done

  echo "Granting mysql permissions."
  bundle exec mysql -h mysql -e "GRANT ALL ON *.* TO 'chords_demo_user';"

  echo "Creating rails database."
  bundle exec rake db:create
else
  echo "**** $seeded_flag was found. Database will not be created."
fi

echo "Migrating rails database."
bundle exec rake db:migrate

if [ !  -e $seeded_flag ]; then
  echo "**** $seeded_flag not found. Seeding rails database."
  bundle exec rake db:seed
else
  echo "**** $seeded_flag was found. Database will not be seeded."
fi

# Database ready. Set the SEEDED flag.
touch $seeded_flag

echo "Starting web server."
mkdir -p tmp/pids/
rm -f tmp/pids/unicorn.pid
unicorn -p 80 -c ./config/unicorn.rb

