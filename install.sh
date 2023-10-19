#!/bin/sh
#set -x

install_root=/usr/local/deploy-compose
user_scripts=$install_root/scripts-user

if [ "$1" = "--help" || "$1" = "-h" ]; then
  echo "Usage: $0"
  echo \nInstalls deploy-compose scripts in $install_root
  exit 0
fi

echo Installing deploy-compose

echo "> copying scripts to $install_root"

if [ ! -d "$install_root" ]; then
  sudo mkdir -p $install_root
fi

sudo cp -r scripts-admin/. $install_root
sudo cp -r scripts-user $install_root

echo "sudo $user_scripts/deploy.sh" > $user_scripts/deploy
echo "sudo $user_scripts/list-containers.sh" > $user_scripts/list-containers
echo "sudo $user_scripts/log-show.sh" > $user_scripts/log-show
echo "sudo $user_scripts/log-tail.sh" > $user_scripts/log-tail
echo "sudo $user_scripts/run-bash.sh" > $user_scripts/run-bash
echo "sudo $user_scripts/stop-containers" > $user_scripts/stop-containers
echo "sudo $user_scripts/start-containers" > $user_scripts/start-containers
echo "sudo $user_scripts/create-containers" > $user_scripts/create-containers

sudo chmod -R +x $install_root

echo "> creating deploy_user group"
sudo groupadd deploy_user

echo "> adding deploy_user group to sudoers"
sudo_file=/etc/sudoers.d/deploy-compose
sudo echo "%deploy_user ALL=(ALL) NOPASSWD: !ALL" > $sudo_file
sudo echo "%deploy_user ALL=(ALL) NOPASSWD: $user_scripts/*" >> $sudo_file

echo Done.