#!/bin/bash

# Cleanup first
docker-compose down

# Start a redis + filebeat with the config
docker-compose up -d

# Repetitively start short lived containers outputting 1 log of output each
for i in `seq 1 512`; do
  echo "$i"
  docker run -it --rm -d alpine:3.10 date
done

# Get the filebeat logs
docker-compose logs filebeat
