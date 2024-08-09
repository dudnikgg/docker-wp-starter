#!/bin/bash

Color_off='\033[0m' # Text Reset
Red='\033[0;31m' # Red
Green='\033[0;32m' # Green

# Source the .env file
source .env

echo -e "$Green # The project dev url is: $PROJECT_DEV_URL $Color_off"

# Exit if any command fails
set -e

if [ -z "$PROJECT_DEV_URL" ] || [ -z "$REMOTE_SERVER" ] || [ -z "$REMOTE_PROJECT_PATH" ]; then
  echo -e "$Red # PROJECT_DEV_URL or REMOTE_SERVER or REMOTE_PROJECT_PATH is not set $Color_off"
  exit 1
fi

echo -e "$Green # Exporting staging mysql... $Color_off"
ssh "$REMOTE_SERVER" "cd \"$REMOTE_PROJECT_PATH\" && docker compose run --rm wp-cli wp db export ../db-dump/db-dump.sql"

echo -e "$Green # Fetching backup from dev server... $Color_off"
# connect to remote server and copy file from remote to local
scp "$REMOTE_SERVER":"$REMOTE_PROJECT_PATH/db-dump/db-dump.sql" ./db-dump

echo -e "$Green # Importing via wp cli in docker... $Color_off"
docker compose run --rm wp-cli wp db import ../db-dump/db-dump.sql --allow-root

echo -e "$Green # Replacing domain names... $Color_off"
docker compose run --rm wp-cli wp search-replace $PROJECT_DEV_URL localhost --all-tables --url=localhost --allow-root

docker compose run --rm wp-cli wp search-replace https://localhost http://localhost --all-tables --url=localhost --allow-root

docker compose run --rm wp-cli wp option get siteurl --allow-root

echo -e "$Green # Re-creating local user... $Color_off"
user_id=$(docker compose run --rm wp-cli wp user create local dev@local.dd --url=localhost --role=administrator --user_pass=local | awk '{print $NF}')
docker compose run --rm wp-cli wp super-admin add $user_id