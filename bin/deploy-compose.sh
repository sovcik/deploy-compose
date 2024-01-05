#!/bin/bash

#set -x

this_user=$USER
if [ "$SUDO_USER" != "" ]; then
  this_user=$SUDO_USER
fi

sript_name=docker-compose

show_help() {
  echo "Usage: $script_name [options] <command> [command args]"
  echo
  echo "Options:"
  echo "  --help, -h - show this help"
  echo "  --application, -a - application name, defualt: none"
  echo "  --user, -u - user name, default: $this_user"
  echo
  echo "Commands:"
  echo "  connect <container_name> - connect to shell in the container"
  echo "  create - create docker containers used by project"
  echo "  deploy - deploy docker compose project using configuration in .deploy folder"
  echo "  exec <container_name> <command> [command args] - execute command in the container"
  echo "  list - list docker containers used by project"
  echo "  log-show <container_name> - show logs of the container"
  echo "  log-tail <container_name> - tail logs of the container"
  echo "  pull - pull + refresh docker containers used by project"
  echo "  start - start docker containers used by project"
  echo "  stop - stop docker containers used by project"
  echo
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --help|-h)
      show_help
      exit 0
      ;;

    --user|-u)
      if [ "$2" = "" ]; then
        echo "Error: provide user name as the second argument"
        exit 1
      fi
      this_user="$2"
      shift
      shift
      ;;

    --application|-a)
      if [ "$2" = "" ]; then
        echo "Error: provide application name as the second argument"
        exit 1
      fi
      app_name="$2"
      shift
      shift
      ;;

    *)
      break
      ;;
  esac
done


# path where deploy-compose is installed and where user folders are created
data_dir=/usr/local/lib/deploy-compose

config_file=/etc/deploy-compose.cfg

if [ -e "$config_file" ]; then
  . $config_file
fi

# path to user folder
user_path=$data_dir/users/$this_user

# path to user home folder
user_home_folder=/home/$this_user

# docker compose file name
dc_file=docker-compose.yaml

# path to user folder with current configuration
current_config_folder=$user_path/current
if [ "$app_name" != "" ]; then
  current_config_folder=$user_path/current/$app_name
fi

# full current docker compose file name
current_config="$current_config_folder/$dc_file"

# docker compose project name
project_name="$this_user"
if [ "$app_name" != "" ]; then
  project_name="$this_user-$app_name"
fi

####################################################################################################
login() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name login <username> <password>"
    echo
    echo Login to docker hub
    exit 0
  fi

  sudo docker login "$1" "$2"

}

####################################################################################################
deploy() {

  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
    echo Deploys docker compose project using configuration in .deploy folder
    exit 0
  fi

  # path to user folder with new configuration
  local user_new_config_root=$user_home_folder/.deploy
  local user_new_config_folder=$user_new_config_root

  if [ "$app_name" != "" ]; then
    user_new_config_folder=$user_new_config_root/$app_name
    if [ ! -d "$user_new_config_folder" ]; then
      echo "Error: no $app_name folder found in $user_new_config_root."
      exit 1
    fi
  fi

  if [ ! -f "$user_new_config_folder/$dc_file" ]; then
    echo "Error: no $dc_file found in folder=$user_new_config_folder."
    exit 1
  fi

  if [ ! -d "$user_path/archive" ]; then
    echo "Error: folder $user_path/archive does not exist"
    exit 1
  fi

  echo "Deploying using configuration in $user_new_config_folder folder"

  dt=$(date '+%Y%m%d_%H%M%S')

  if [ ! -d "$current_config_folder" ]; then
    sudo mkdir -p $current_config_folder
  fi

  if [ -f "$current_config" ]; then
    echo "> stopping services using current compose file"
    sudo docker compose -f "$current_config" --project-name $project_name down

    echo "> archiving the current deploy files"
    sudo tar czf $user_path/archive/deploy_${project_name}_${dt}.tar.gz -C $current_config_folder/ .
    sudo rm $current_config_folder/*
  fi

  echo "> making new compose files current"
  sudo cp -r $user_new_config_folder/. $current_config_folder/

  echo "> giving read access to new and archived files to $this_user"
  sudo chown -R root:$this_user $user_path/current
  sudo chown -R root:$this_user $user_path/archive
  sudo chmod -R o= $user_path
  sudo chmod -R g-w $user_path

  echo "> pulling new images"
  sudo docker compose -f "$current_config" --project-name $project_name pull

  echo "> starting services using new compose files"
  # navigate to current config folder, so docker compose can find .env file
  pushd $current_config_folder
  sudo docker compose -f "$dc_file" --project-name $project_name up -d
  if [ $? -ne 0 ]; then
    echo "Error: failed to start services"
    popd
    exit 1
  fi
  popd

  echo ""
  echo You can access current and archived deploy files at $user_path
  echo ""
  echo Done.
}

####################################################################################################
connect() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Connects to shell in the container
    echo "  <container_name> - name of the container to connect to"
    exit 0
  fi

  if [ "$1" = "" ]; then
    echo "Error: provide container name as the first argument"
    exit 1
  fi

  sudo docker exec -i -t $1 /bin/bash
}

####################################################################################################
create() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Create docker containers used by project
    exit 0
  fi

  pushd $current_config_folder
  sudo docker compose -f "$dc_file" --project-name $project_name create
  popd
}

####################################################################################################
exec_cmd() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name exec <container_name> <command> [command args]"
    echo
    echo Executes command in the container
    echo "  <container_name> - name of the container to connect to"
    echo "  <command> - command to run in the container"
    echo "  [command args] - arguments for the command"
    exit 0
  fi

  if [ "$1" = "" ]; then
    echo "Error: provide container name as the first argument"
    exit 1
  fi

  if [ "$2" = "" ]; then
    echo "Error: provide command as the second argument"
    exit 1
  fi

  sudo docker exec -i -t $@
}

####################################################################################################
list() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo List docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name ps
}

####################################################################################################
show_log(){
  if [ "$1" = "" ]; then
    echo "Error: provide container name as the first argument"
    exit 1
  fi

  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Shows logs of the container
    echo "  <container_name> - name of the container to show logs for"
    exit 0
  fi

  less -F `sudo docker inspect --format='{{.LogPath}}' $1`
}

####################################################################################################
tail_log() {
  if [ "$1" = "" ]; then
    echo "Error: provide container name as the first argument"
    exit 1
  fi

  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Tail logs of the container
    echo "  <container_name> - name of the container to show logs for"
    exit 0
  fi

  tail -f `sudo docker inspect --format='{{.LogPath}}' $1`
  }

####################################################################################################
pull() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Pull + refresh docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name pull    
}

####################################################################################################
start() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Start docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name start
}

####################################################################################################
stop() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo Stop docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name stop
}

####################################################################################################

command=$1
shift

case $command in 
  login ) 
    login "$@";;
	connect ) 
    connect "$@";;
  create ) 
    create "$@";;
  deploy ) 
    deploy "$@";;
  exec ) 
    exec_cmd "$@";;
  list ) 
    list "$@";;
  log-show ) 
    show_log "$@";;
  log-tail ) 
    tail_log "$@";;
  pull ) 
    pull "$@";;
  start ) 
    start "$@";;
  stop ) 
    stop "$@";;
	* ) echo Error: unknown command $command;
    show_help;
		exit 1;;
esac