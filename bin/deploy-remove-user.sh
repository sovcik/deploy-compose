#!/bin/bash
#set -x

if [ "$1" = "" ]; then
  echo "Error: provide username as the first argument"
  exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0 <container_name>"
  echo
  echo Remove deployment user including all their files and containers
  exit 0
fi

this_user=$1

read -p "Do you want to remove deployment & system user '$this_user'? (yes/no) " yn

case $yn in 
	yes ) echo ok, we will proceed;;
	* ) echo exiting...;
		exit 1;;
esac

root_path=/usr/local/lib/deploy-compose
user_deploy_folder=$root_path/users/$this_user
compose_file=$user_deploy_folder/current/docker-compose.yaml

echo Removing deploy user $this_user

echo "> removing docker containers and images (may take several minutes)"
# stop user's project
docker compose -f $compose_file down

# remove stopped projects containers
docker compose -f $compose_file rm

# remove images not used by any containers
docker image prune --all --force

echo "> removing deployment files"
# remove user deploy files and archive
rm -rf $user_deploy_folder

echo "> removing system user"

# remove used from 'deploy_user' group
gpasswd -d $this_user deploy_user

# remove user
userdel -r $this_user

echo Done.