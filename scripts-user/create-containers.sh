#!/bin/bash
#set -x

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0"
  echo
  echo Create docker containers used by project
  exit 0
fi

sudo docker compose -f $user_path/current/$dc_file --project-name $project_name create