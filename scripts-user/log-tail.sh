#!/bin/sh

if [ "$1" = "" ]; then
  echo "Error: provide container name as the first argument"
  exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0 <container_name>"
  echo
  echo Tail logs of the container
  echo "  <container_name> - name of the container to show logs for"
  exit 0
fi

tail -f `docker inspect --format='{{.LogPath}}' $1`