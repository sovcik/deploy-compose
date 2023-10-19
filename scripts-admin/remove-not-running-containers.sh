#!/bin/bash

# Get a list of all containers
containers=$(docker ps -a -q)

# Check if there are any containers
if [[ -z "$containers" ]]; then
  echo "No Docker containers found."
  exit 0
fi

# Check the status of each container
for container in $containers; do
  status=$(docker inspect -f '{{.State.Status}}' $container)

  # Remove the container if it is not running
  if [[ $status != "running" ]]; then
    echo "Removing container: $container"
    docker rm $container
  fi
done

echo "Not running Docker containers have been removed."