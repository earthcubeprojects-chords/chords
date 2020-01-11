#!/bin/sh


read_var() {
    VAR=$(grep $1 $2 | xargs)
    IFS="=" read -ra VAR <<< "$VAR"
    echo ${VAR[1]}
}



if test -f ".env"; 
then
  SSL_ENABLED=$(read_var SSL_ENABLED .env)
  SSL_HOST=$(read_var SSL_HOST .env)
  SSL_CERT_EMAIL=$(read_var SSL_CERT_EMAIL .env)
else
    echo ".env not found in current directory"
fi


if [ -z ${SSL_ENABLED+x} ]; 
then 
  echo "SSL_ENABLED is unset"; 
  abort="true"
fi


if [[ $SSL_ENABLED = "true" ]]
then
  echo ""; 
else
  echo "SSL_ENABLED must be set to \"true\""; 
  abort="true"  
fi




if [ -z ${SSL_HOST+x} ]; 
then 
  echo "SSL_HOST is unset"; 
  abort="true"
fi


if [ -z ${SSL_CERT_EMAIL+x} ]; 
then 
  echo "SSL_CERT_EMAIL is unset"; 
  abort="true"
fi




if [[ $abort = "true" ]]
then
  echo "\naborting...\n"
else
  echo "installing ssl certificates"

  # create the dhparam key file
  docker-compose run web /chords/create_dh_param_key.sh

  # generate temp certificates
  docker-compose run certbot certonly --webroot --webroot-path=/chords/public --email ${SSL_CERT_EMAIL} --agree-tos --no-eff-email --staging -d ${SSL_HOST}


  # build the web container with SSL_ENABLED=true to generate the temporary certificate
  docker-compose down
  docker-compose -f ./docker-compose.yml -f ./docker-compose-dev.yml build --no-cache web
  docker-compose -f ./docker-compose.yml -f ./docker-compose-dev.yml up -d


  # generate actual certifcates
  # docker-compose run certbot certonly --webroot --webroot-path=/chords/public --email ${SSL_CERT_EMAIL} --agree-tos --no-eff-email  --force-renewal --dry-run -d ${SSL_HOST}
  docker-compose run certbot certonly --webroot --webroot-path=/chords/public --email ${SSL_CERT_EMAIL} --agree-tos --no-eff-email  --force-renewal  -d ${SSL_HOST}


  #restart the web server
  docker-compose -f ./docker-compose.yml -f ./docker-compose-dev.yml up -d --force-recreate --no-deps web
fi
