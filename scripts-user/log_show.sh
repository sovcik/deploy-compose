#!/bin/sh

if [ "$1" = "" ]; then
  echo "Error: provide container name as the first argument"
  exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0 <container_name>"
  echo \nShows logs of the container
  echo "  <container_name> - name of the container to show logs for"
  exit 0
fi

CONTAINER=$1
less -F `docker inspect --format='{{.LogPath}}' $CONTAINER`
