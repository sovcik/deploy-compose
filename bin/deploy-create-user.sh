#!/bin/bash
#set -x

show_help() {
  echo "Usage: $0 [options] <username>"
  echo
  echo Creates a new user for deployment
  echo "  <username> - name of the user to create"
  echo
  echo "Options:"
  echo "  -h, --help    show this help message and exit"
  echo "  -s, --sys-user    create system user"
  echo "  -k <key>, --ssh-key <key>    ssh public key of the user"
  echo
}

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    -k | --ssh-key )        shift
                            public_key=$1
                            ;;
    -h | --help )           show_help
                            exit
                            ;;
    -s | --sys-user )       sys_user=true
                            ;;
    * )                     break
  esac
  shift
done

if [ "$1" = "" ]; then
  echo "Error: provide username as the first argument"
  exit 1
fi

if [ "$public_key" = "" ]; then
  echo "Error: provide user's ssh public key"
  exit 1
fi

this_user=$1

user_home=/home/$this_user

# path where deploy-compose is installed and where user folders are created
data_dir=/usr/local/lib/deploy-compose

config_file=/etc/deploy-compose.cfg

if [ -e "$config_file" ]; then
  . $config_file
fi

echo "Creating deploy user: $this_user"

echo "> creating deploy folders"
mkdir -p $data_dir/users/$this_user/archive
mkdir -p $data_dir/users/$this_user/current

if [ "$sys_user" = true ]; then
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

  echo "> giving user read-only access to deploy folders at $data_dir/users/$this_user"
  chown -R root:$this_user $data_dir/users/$this_user
  chmod -R o= $data_dir/users/$this_user
  chmod -R g-w $data_dir/users/$this_user

fi

echo Done.