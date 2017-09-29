#!/bin/bash

if ! type "docker-compose" &> /dev/null; then
  echo "Please install Docker and try running the script again"
  exit 1
fi

docker-compose stop

if [ $? -ne 0 ]; then
  echo "There was an error stopping Ame. Please consult the log and file an issue if appropriate"
  exit 1
fi

echo "Ame has been stopped, sweet dreams"
