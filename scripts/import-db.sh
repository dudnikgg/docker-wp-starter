#!/bin/zsh

Color_off=$(tput sgr0) # Text Reset
Red=$'\e[0;31m' # Red
Yellow=$'\e[0;33m' # Yellow
Green=$'\e[0;32m' # Green

# Source the .env file
source "$(dirname "$0")/../.env"

echo "$Green # The project local url is: $PROJECT_LOCAL_URL $Color_off"
echo "$Green # The project live url is: $PROJECT_DEV_URL $Color_off"

# Exit if any command fails
set -e

echo "$Yellow # Importing via wp cli in docker... $Color_off"
docker compose run --rm wp-cli wp db import /var/www/db-dump/start.sql --allow-root

echo "$Yellow # Replacing domain names... $Color_off"
docker compose run --rm wp-cli wp search-replace $PROJECT_DEV_DOMAIN $PROJECT_LOCAL_DOMAIN --all-tables --allow-root
docker compose run --rm wp-cli wp search-replace https://$PROJECT_LOCAL_DOMAIN http://$PROJECT_LOCAL_DOMAIN --all-tables --allow-root

docker compose run --rm wp-cli wp option get siteurl --allow-root

echo "$Yellow # Re-creating local user... $Color_off"
docker compose run --rm wp-cli wp user create local local@dev.dd --role=administrator --user_pass=local --allow-root
