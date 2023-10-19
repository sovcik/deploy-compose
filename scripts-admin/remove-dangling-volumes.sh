#!/bin/bash

# Get a list of all dangling volumes
dangling_volumes=$(docker volume ls -qf dangling=true)

# Check if there are any dangling volumes
if [[ -z "$dangling_volumes" ]]; then
  echo "No dangling Docker volumes found."
  exit 0
fi

# Remove each dangling volume
for volume in $dangling_volumes; do
  echo "Removing dangling volume: $volume"
  docker volume rm $volume
done

echo "Dangling Docker volumes have been removed."