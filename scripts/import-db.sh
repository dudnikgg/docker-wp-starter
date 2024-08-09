#!/bin/bash

Color_off='\033[0m' # Text Reset
Red='\033[0;31m' # Red
Green='\033[0;32m' # Green

# Source the .env file
source .env

echo "$Green # The project name is: localhost $Color_off"
echo "$Green # The project live url is: $PROJECT_DEV_URL $Color_off"

# Exit if any command fails
set -e

echo "$Green # Importing via wp cli in docker... $Color_off"
docker compose run --rm wp-cli wp db import /var/www/db-dump/db_dump.sql --allow-root

echo "$Green # Replacing domain names... $Color_off"
docker compose run --rm wp-cli wp search-replace $PROJECT_DEV_URL http://localhost --all-tables --url=localhost --allow-root

docker compose run --rm wp-cli wp option get siteurl --allow-root

echo "$Green # Re-creating local user... $Color_off"
docker compose run --rm wp-cli wp user create local local@dev.dd --role=administrator --user_pass=local --allow-root