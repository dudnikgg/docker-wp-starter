#!/bin/bash

Color_off='\033[0m' # Text Reset
Red='\033[0;31m' # Red
Green='\033[0;32m' # Green

# Source the .env file
source .env

# Exit if any command fails
set -e

if [ -z "$ABS_PATH_TO_UPLOADS" ] || [ -z "$REMOTE_SERVER" ] || [ -z "$REMOTE_PROJECT_PATH" ]; then
  echo -e "$Red # ABS_PATH_TO_UPLOADS or REMOTE_SERVER or REMOTE_PROJECT_PATH is not set $Color_off"
  exit 1
fi

echo -e "$Green # Fetching assets from prod... $Color_off"
rsync -rzav --progress $REMOTE_SERVER":"$REMOTE_PROJECT_PATH/wp-uploads/ $ABS_PATH_TO_UPLOADS

echo -e "$Green # Regenerating images... $Color_off"
docker-compose run --rm wp-cli wp media regenerate --yes