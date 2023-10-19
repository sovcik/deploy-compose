#!/bin/bash
#set -x

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0"
  echo
  echo Create docker containers used by project
  exit 0
fi

this_user=$USER
if [ "$SUDO_USER" != "" ]; then
  this_user=$SUDO_USER
fi

sudo docker compose -f $user_path/current/$dc_file --project-name $this_user create