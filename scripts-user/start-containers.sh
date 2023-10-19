#!/bin/bash
#set -x

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0"
  echo
  echo Stop docker containers used by project
  exit 0
fi

this_user=$USER
if [ "$SUDO_USER" != "" ]; then
  this_user=$SUDO_USER
fi

dc_file=docker-compose.yml
root_path=/usr/local/lib/deploy-compose
user_path=$root_path/users/$this_user

sudo docker compose -f $user_path/current/$dc_file --project-name $this_user start