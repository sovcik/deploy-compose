#!/bin/bash
#set -x

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

show_help() {
  echo "Usage: $0 [options] <username>"
  echo
  echo Creates an application for deployment
  echo "  <name> - name of the application to create"
  echo
  echo "Options:"
  echo "  -h, --help    show this help message and exit"
  echo "  -u, --user    create app for specific user"
  echo
}

this_user=$USER
if [ "$SUDO_USER" != "" ]; then
  this_user=$SUDO_USER
fi

user_name=$this_user

while [ "$1" != "" ]; do
  case $1 in
    -h | --help )           show_help
                            exit
                            ;;
    -u | --user )           user_name=$2
                            shift
                            ;;
    * )                     break
  esac
  shift
done

if [ "$1" = "" ]; then
  echo "Error: application name not provided"
  exit 1
fi
app_name=$1

user_home=/home/$user_name

# path where deploy-compose is installed and where user folders are created
data_dir=/usr/local/lib/deploy-compose

config_file=/etc/deploy-compose.cfg

if [ -e "$config_file" ]; then
  . $config_file
fi

echo "Creating application for user: $user_name"

echo "> creating application folder in deploy folder"
mkdir -p $user_home/.deploy/$app_name

mkdir -p $data_dir/users/$user_name/archive/$app_name
mkdir -p $data_dir/users/$user_name/current/$app_name

echo "> giving read-only user access to deploy folders at $data_dir/users/$user_name"
chown -R root:$user_name $data_dir/users/$user_name
chmod -R g-w $data_dir/users/$user_name
chmod -R o= $data_dir/users/$user_name

echo Done.