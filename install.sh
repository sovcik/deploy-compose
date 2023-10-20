#!/bin/sh
#set -x

install_root=/usr/local/lib/deploy-compose
bin_root=/usr/local/bin

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0"
  echo
  echo Installs deploy-compose scripts in $install_root
  exit 0
fi

echo Installing deploy-compose

echo "> copying scripts to $install_root"

if [ ! -d "$install_root/users" ]; then
  sudo mkdir -p $install_root/users
fi

sudo cp -r bin $bin_root
sudo chmod -R +x $bin_root/*.sh

echo "> creating deploy_user group"
sudo groupadd deploy_user

echo "> adding deploy_user group to sudoers"
sudo_file=/etc/sudoers.d/deploy-compose
echo "%deploy_user ALL=(ALL) NOPASSWD: !ALL" | sudo tee $sudo_file > /dev/null
echo "%deploy_user ALL=(ALL) NOPASSWD: $bin_root/deploy-compose.sh" | sudo tee -a $sudo_file > /dev/null

echo Done.