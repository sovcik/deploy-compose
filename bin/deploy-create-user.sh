#!/bin/sh
#set -x

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  echo "Usage: $0 <username> <ssh_public_key>"
  echo
  echo Creates a new user for deployment
  echo "  <username> - name of the user to create"
  echo "  <ssh_public_key> - ssh public key of the user. It has to be enclosed on quotes"
  exit 0
fi

if [ "$1" = "" ]; then
  echo "Error: provide username as the first argument"
  exit 1
fi

if [ "$2" = "" ]; then
  echo "Error: provide user's ssh public key as the second argument"
  exit 1
fi

this_user=$1
public_key=$2
root_folder=/usr/local/deploy-compose
user_scripts=$root_folder/scripts-user
user_home=/home/$this_user

echo "Creating deploy user: $this_user"

echo "> creating system user"
useradd -m --user-group --shell /usr/bin/bash $this_user

echo "> configuring system user"
# set special password, so user can't change or enter password
# add user to 'deploy_user' group, which is allowed to use sudo
# for deploy
usermod --password '*' --append --groups deploy_user $this_user

# create folder required by ssh
mkdir $user_home/.ssh

# create folder for deployment files
mkdir $user_home/.deploy


echo "> adding provided ssh public key to authorized keys"
# so user can connect using ssh using his private key
echo $public_key > $user_home/.ssh/authorized_keys

# set correct permissions for newly created folders and files
chown -R $this_user:$this_user $user_home/.ssh
chmod 700 $user_home/.ssh
chmod 600 $user_home/.ssh/authorized_keys

chown -R $this_user:$this_user $user_home/.deploy
chmod o= $user_home/.deploy

echo "> adding path to deploy scripts to user's PATH"
# add path to deploy scripts to user's PATH
echo "export PATH=$PATH:$user_scripts" >> $user_home/.bashrc

echo "> creating deploy folders"
mkdir -p $root_folder/users/$this_user/archive
mkdir -p $root_folder/users/$this_user/current

echo "> giving user read-only access to deploy folders at $root_folder/users/$this_user"
chown -R root:$this_user $root_folder/users/$this_user
chmod -R o= $root_folder/users/$this_user

echo Done.