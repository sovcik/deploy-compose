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

echo "sudo $user_scripts/deploy.sh" | sudo tee $user_scripts/deploy > /dev/null
echo "sudo $user_scripts/list-containers.sh" | sudo tee $user_scripts/list-containers > /dev/null
echo "sudo $user_scripts/log-show.sh" | sudo tee $user_scripts/log-show > /dev/null
echo "sudo $user_scripts/log-tail.sh" | sudo tee $user_scripts/log-tail > /dev/null
echo "sudo $user_scripts/run-bash.sh" | sudo tee $user_scripts/run-bash > /dev/null
echo "sudo $user_scripts/stop-containers" | sudo tee $user_scripts/stop-containers > /dev/null
echo "sudo $user_scripts/start-containers" | sudo tee $user_scripts/start-containers > /dev/null
echo "sudo $user_scripts/create-containers" | sudo tee $user_scripts/create-containers > /dev/null

sudo chmod -R +x $install_root

echo "> creating deploy_user group"
sudo groupadd deploy_user

echo "> adding deploy_user group to sudoers"
sudo_file=/etc/sudoers.d/deploy-compose
echo "%deploy_user ALL=(ALL) NOPASSWD: !ALL" | sudo tee $sudo_file > /dev/null
echo "%deploy_user ALL=(ALL) NOPASSWD: $user_scripts/*" | sudo tee -a $sudo_file > /dev/null

echo Done.