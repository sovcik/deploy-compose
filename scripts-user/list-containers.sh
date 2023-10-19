#!/bin/bash
#set -x

if [ "$1" = "--help" || "$1" = "-h" ]; then
  echo "Usage: $0"
  echo \nList docker containers used by project
  exit 0
fi

sudo docker compose ps -a