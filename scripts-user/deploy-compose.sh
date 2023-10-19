#!/bin/sh

#set -x

sript_name=docker-compose

show_help() {
  echo "Usage: $script_name <command> [command args]"
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
  echo "  --help, -h - show this help"
  echo
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  show_help
  exit 0
fi

this_user=$USER
if [ "$SUDO_USER" != "" ]; then
  this_user=$SUDO_USER
fi

# path where deploy-compose is installed and where user folders are created
install_folder=/usr/local/lib/deploy-compose

# path to user folder
user_path=$install_folder/users/$this_user

# path to user home folder
user_home_folder=/home/$this_user

# docker compose file name
dc_file=docker-compose.yaml

# path to user folder with current configuration
user_current_config_folder=$user_path/current

# docker compose project name
project_name="$this_user"

# full current docker compose file name
current_config="$user_path/current/$dc_file"

####################################################################################################
deploy() {

  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
    echo Deploys docker compose project using configuration in .deploy folder
    exit 0
  fi

  # path to user folder with new configuration
  local user_new_config_folder=$user_home_folder/.deploy

  if [ ! -f "$user_new_config_folder/$dc_file" ]; then
    echo "Error: no $dc_file found in folder=$user_new_config_folder."
    exit 1
  fi

  if [ ! -x "$user_path/archive" ]; then
    echo "Error: archive folder for user $this_user does not exist"
    exit 1
  fi

  echo "Deploying using configuration in .deploy folder"

  dt=$(date '+%Y%m%d_%H%M%S')
  
  if [ -f "$current_config" ]; then
    echo "> stopping services using current compose file"
    sudo docker compose -f "$current_config" down

    echo "> archiving the current deploy files"
    sudo tar czf $user_path/archive/deploy_${this_user}_${dt}.tar.gz -C $user_path/current/ .
    sudo rm $user_path/current/*
  fi

  echo "> making new compose files current"
  sudo cp -r $user_new_config_folder/. $user_path/current


  echo "> giving read access to new and archived files to $this_user"
  sudo chown -R root:$this_user $user_path/current
  sudo chown -R root:$this_user $user_path/archive
  sudo chmod -R o= $user_path

  echo "> starting services using new compose files"
  sudo docker compose -f "$current_config" --project-name $project_name up -d

  echo ""
  echo You can access current and archved deploy files at $user_path
  echo ""
  echo Done.
}

####################################################################################################
connect() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0 <container_name>"
    echo
    echo Connects to shell in the container
    echo "  <container_name> - name of the container to connect to"
    exit 0
  fi

  if [ "$1" = "" ]; then
    echo "Error: provide container name as the first argument"
    exit 1
  fi

  sudo docker run -i -t $1 bash
}

####################################################################################################
create() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
    echo Create docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name create
}

####################################################################################################
exec() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0 <container_name> <command> [command args]"
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

  sudo docker run -i -t $@
}

####################################################################################################
list() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
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
    echo "Usage: $script_name $0 <container_name>"
    echo
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
    echo "Usage: $script_name $0 <container_name>"
    echo
    echo Tail logs of the container
    echo "  <container_name> - name of the container to show logs for"
    exit 0
  fi

  tail -f `sudo docker inspect --format='{{.LogPath}}' $1`
  }

####################################################################################################
pull() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
    echo Pull + refresh docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name pull    
}

####################################################################################################
start() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
    echo Start docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name start
}

####################################################################################################
stop() {
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $script_name $0"
    echo
    echo Stop docker containers used by project
    exit 0
  fi

  sudo docker compose -f "$current_config" --project-name $project_name stop
}

####################################################################################################

command=$1

case $command in 
	connect ) 
    connect "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  create ) 
    create "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  deploy ) 
    deploy "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  exec ) 
    exec "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  list ) 
    list "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  log-show ) 
    show_log "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  log-tail ) 
    tail_log "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  pull ) 
    pull "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  start ) 
    start "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
  stop ) 
    stop "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9";;
	* ) echo Error: unknown command $command;
    show_help;
		exit 1;;
esac