#!/bin/bash

if ! type "composer" &> /dev/null; then
  echo "Please install composer and try running the script again"
  echo "Installation instructions can be found at https://getcomposer.org/download"
  exit 1
fi

if ! type "npm" &> /dev/null; then
  echo "Please install Node and try running the script again"
  echo "Installation instructions can be found at https://nodejs.org/en/download"
  exit 1
fi

if ! type "docker-compose" &> /dev/null; then
  echo "Please install Docker and try running the script again"
  echo "Installation instructions can be found at https://www.docker.com/community-edition"
  exit 1
fi

if ! type "drush" &> /dev/null; then
  echo "Please install Drush and try running the script again"
  echo "Installation instructions can be found at http://docs.drush.org/en/8.x/install"
  exit 1
fi

DOCKER_VERSION=$(docker -v | sed 's/Docker version //')
DOCKER_VERSION=(${DOCKER_VERSION//./ })

if [ ${DOCKER_VERSION[0]} -lt 17 ] || ( [ ${DOCKER_VERSION[0]} -eq 17 ] && [ ${DOCKER_VERSION[1]} -lt 6 ] ); then
  echo "Please upgrade Docker to version 17.05 or later and try running the script again"
  exit 1
fi

if [ ! -d "ame" ]; then
  echo "Installing Ame to ./ame"
  composer create-project mortenson/ame-project ame -s dev --repository '{"type": "vcs","url":  "git@github.com:mortenson/ame-project.git"}' --keep-vcs --no-interaction
  if [ $? -ne 0 ]; then
    echo "Project creation failed. Please consult the log and file an issue if appropriate"
    exit 1
  fi
  cp ame/web/sites/default/default.settings.php ame/web/sites/default/settings.php
  cat settings.php.txt >> ame/web/sites/default/settings.php
  cd ame/web/modules/contrib/stencil && npm install && cd -
  NEW_INSTALL=1
fi

docker-compose up -d

if [ $? -ne 0 ]; then
  echo "Ame startup failed. Please consult the log and file an issue if appropriate"
  exit 1
fi

if [[ $NEW_INSTALL ]]; then
  drush site-install ame -y
  if [ $? -ne 0 ]; then
    echo "Ame installation failed. Please consult the log and file an issue if appropriate"
    exit 1
  fi
fi

if [[ $NEW_INSTALL ]]; then
  URL=$(drush uli | tr -d '\r')
else
  URL=http://$(docker-compose port php 80 | sed 's/0.0.0.0/localhost/')
fi

if type "open" &> /dev/null; then
  open $URL
elif type "xdg-open" &> /dev/null; then
  xdg-open $URL
else
  echo "Ame has been started"
fi
