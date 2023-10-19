#!/bin/sh

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0 <container_name>"
  echo
  echo Connects to shell in the container
  echo "  <container_name> - name of the container to connect to"
  exit 0
fi

if [ "$1" = "" ]; then
  echo "Error: provide container name as the first argument"
  exit 1
fi

sudo docker run -i -t $1 bash