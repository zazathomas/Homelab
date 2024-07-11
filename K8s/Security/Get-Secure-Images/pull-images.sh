# !/bin/bash

# Export DOCKER_USER and DOCKER_PASS before running the script

# Exit if any command fails
set -e

# Initialize variables
cg_image=${1}
my_image=${2}

# Pull images
docker pull $cg_image

# Tag image
docker tag $cg_image $my_image

# Login to Docker Hub
echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

# Push image
docker push $my_image

# Logout from Docker Hub
docker logout

# Remove images
docker rmi $cg_image -f
docker rmi $my_image -f