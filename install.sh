#!/bin/bash
#set -x

data_dir=/usr/local/lib/deploy-compose
bin_dir=/usr/local/bin
config_file=/etc/deploy-compose.cfg
config_found=false

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo Installs deploy-compose scripts
  echo
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h, --help    show this help message and exit"
  echo "  -d, --dir     specify data directory, default: $data_dir"
  exit 0
fi

if [ -e "$config_file" ]; then
  echo "deploy-compose configuration found in $config_file"
  . $config_file
  config_found=true
elif [ "$1" = "--dir" ] || [ "$1" = "-d" ]; then
  if [ -z "$2" ]; then
    echo "Error: no data directory specified"
    exit 1
  fi
  data_dir=$2
fi

if [ "$config_found" = false ]; then
  echo "> creating deploy-compose configuration in $config_file"
  echo "data_dir=$data_dir" | sudo tee $config_file > /dev/null
fi

echo Installing deploy-compose

if [ ! -d "$data_dir/users" ]; then
  echo "> creating user folders in $data_dir/users"
  sudo mkdir -p $data_dir/users
else
  echo "> user folders already exist in $data_dir/users"
fi

echo "> copying scripts to $bin_dir"
sudo cp -r bin/. $bin_dir/
sudo chmod -R +x $bin_dir/*.sh

echo "> creating deploy_user group"
sudo groupadd deploy_user

echo "> adding deploy_user group to sudoers"
sudo_file=/etc/sudoers.d/deploy-compose
echo "%deploy_user ALL=(ALL) NOPASSWD: !ALL" | sudo tee $sudo_file > /dev/null
echo "%deploy_user ALL=(ALL) NOPASSWD: $bin_dir/deploy-compose.sh" | sudo tee -a $sudo_file > /dev/null

echo Done.