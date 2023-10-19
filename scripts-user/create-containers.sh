#!/bin/bash
#set -x

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0"
  echo \nCreate docker containers used by project
  exit 0
fi

sudo docker compose create 