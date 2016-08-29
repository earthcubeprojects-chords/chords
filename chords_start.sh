#!/bin/bash

server="mysql"
seeded_flag="/chords_log/SEEDED"

# Make sure that the log directory exists
mkdir -p log

# See if there is an existing database
if [ ! -e $seeded_flag ] 
then
  echo "/chords_log/SEEDED not found. We will attempt to create the database."

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
fi

echo "Migrating rails database."
bundle exec rake db:migrate

if [ !  -e $seeded_flag ]; then
  echo "/chords_log/SEEDED not found. Seeding rails database."
  bundle exec rake db:seed
fi

# Database ready. Set the SEEDED flag.
touch chords_log/SEEDED

echo "Starting passsenger."
passenger start --port 80
