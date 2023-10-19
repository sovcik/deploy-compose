#!/bin/sh

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0 <container_name> <command> [command args]"
  echo
  echo Executes command in the container
  echo "  <container_name> - name of the container to connect to"
  echo "  <command> - command to run in the container"
  echo "  [command args] - arguments for the command"
  exit 0
fi

if [ "$1" = "" ]; then
  echo "Error: provide container name as the first argument"
  exit 1
fi

if [ "$2" = "" ]; then
  echo "Error: provide command as the second argument"
  exit 1
fi


sudo docker run -i -t $@