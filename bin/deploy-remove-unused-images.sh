#!/bin/bash

# Get a list of all images
images=$(docker images -q)

# Check if there are any images
if [[ -z "$images" ]]; then
  echo "No Docker images found."
  exit 0
fi

# Check the usage of each image
for image in $images; do
  usage=$(docker image inspect -f '{{.Id}} {{.RepoTags}}' $image | awk '{print $2}')

  # Remove the image if it is not used by any container
  if [[ -z "$usage" ]]; then
    echo "Removing image: $image"
    docker rmi $image
  fi
done

echo "Unused Docker images have been removed."