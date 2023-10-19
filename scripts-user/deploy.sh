#!/bin/sh

#set -x

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0"
  echo
  echo Deploys docker compose project using configuration in .deploy folder
  exit 0
fi

this_user=$USER
if [ "$SUDO_USER" != "" ]; then
  this_user=$SUDO_USER
fi

root_path=/opt/deploy
user_home_folder=/home/$this_user
user_path=$root_path/users/$this_user

dc_file=docker-compose.yaml

user_new_deploy_folder=$user_home_folder/.deploy

if [ ! -f "$user_new_deploy_folder/$dc_file" ]; then
  echo "Error: no $dc_file found in folder=$user_new_deploy_folder."
  exit 1
fi

if [ ! -x "$user_path/archive" ]; then
  echo "Error: archive folder for user $this_user does not exist"
  exit 1
fi

echo "Deploying using configuration in .deploy folder"

dt=$(date '+%Y%m%d_%H%M%S')
project_name=$USER

if [ -f "$user_path/current/$dc_file" ]; then
  echo "> stopping services using current compose file"
  sudo docker compose -f $user_path/current/$dc_file down

  echo "> archiving the current deploy files"
  sudo tar czf $user_path/archive/deploy_${this_user}_${dt}.tar.gz -C $user_path/current/ .
  sudo rm $user_path/current/*
fi

echo "> making new compose files current"
sudo cp -r $user_new_deploy_folder/. $user_path/current


echo "> giving read access to new and archived files to $this_user"
sudo chown -R root:$this_user $user_path/current
sudo chown -R root:$this_user $user_path/archive
sudo chmod -R o= $user_path

echo "> starting services using new compose files"
sudo docker compose -f $user_path/current/$dc_file --project-name $project_name up -d

echo ""
echo You can access current and archved deploy files at $user_path
echo ""
echo Done.