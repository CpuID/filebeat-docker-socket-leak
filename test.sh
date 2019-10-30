#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 6|7"
  echo "Arg specifies the Filebeat version, 6 for 6.x, 7 for 7.x"
  echo "Exact version set in docker-compose.yml"
  exit 1
fi

if [ "$1" != "6" ] && [ "$1" != "7" ]; then
  echo "Invalid version, expected 6 or 7, got $1"
  exit 1
fi
version="$1"
echo "Filebeat major version: ${version}"

# Cleanup first
docker-compose down

# Start a redis
docker-compose up -d redis

# Start a filebeat with the config (on the right version)
docker-compose up -d "filebeat${version}"

# Repetitively start short lived containers outputting 1 log of output each
for i in `seq 1 512`; do
  echo "$i"
  docker run -it --rm -d alpine:3.10 date
done

# Get the filebeat logs
docker-compose logs "filebeat${version}"
