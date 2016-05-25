#!/bin/bash

if [ !  -e "/chords_log/SEEDED" ]; then
  echo "/chords_log/SEEDED not found. Will begin database creation in 10 seconds."
  sleep 10
  echo "Granting mysql permissions."
  bundle exec mysql -h mysql -e "GRANT ALL ON *.* TO 'chords_demo_user';"
  echo "Creating rails database."
  bundle exec rake db:create
fi

echo "Migrating rails database."
bundle exec rake db:migrate

if [ !  -e "/chords_log/SEEDED" ]; then
  echo "/chords_log/SEEDED not found. Seeding rails database."
  bundle exec rake db:seed
  touch chords_log/SEEDED
fi

echo "Starting passsenger."
passenger start --port 80
