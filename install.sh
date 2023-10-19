#!/bin/sh
#set -x

install_root=/usr/local/lib/deploy-compose
bin_root=/usr/local/bin
user_scripts=$install_root

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

sudo cp -r scripts-admin/. $install_root
sudo cp -r scripts-user/. $install_root

sudo chmod +x $install_root/*.sh

echo "sudo $user_scripts/deploy-compose.sh \"\$@\"" | sudo tee $bin_root/deploy-compose > /dev/null
sudo chmod +x $bin_root/deploy-compose

echo "> creating deploy_user group"
sudo groupadd deploy_user

echo "> adding deploy_user group to sudoers"
sudo_file=/etc/sudoers.d/deploy-compose
echo "%deploy_user ALL=(ALL) NOPASSWD: !ALL" | sudo tee $sudo_file > /dev/null
echo "%deploy_user ALL=(ALL) NOPASSWD: $user_scripts/*" | sudo tee -a $sudo_file > /dev/null

echo Done.