#!/bin/bash

set -e 

DOCKER_IMAGE=$1
CONTAINER_NAME=$2
DOCKER_LOGIN=$3
DOCKER_PWD=$4


echo "Display Recieved Variables from CircleCI : ->"
echo "Docker Image Name : $DOCKER_IMAGE"
echo "Docker Container Name : $CONTAINER_NAME"

# Check for arguments
if [[ $# -lt 4 ]] ; then
        echo '[ERROR] You must supply a Docker image, container, login and password'
        exit 1
fi

# Check for running container & stop it before starting a new one
# Error here -> need [[]] instead of [] as empty variable is supplied
if [[ $(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_NAME) = "true" ]]; then
        echo "Docker Container running and will be stopped : $CONTAINER_NAME"
        sudo docker stop $CONTAINER_NAME
fi

if [ $(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_NAME) = "true" ]; then
sudo docker stop $CONTAINER_NAME
fi

echo "Starting Docker image name: $DOCKER_IMAGE"

echo $DOCKER_PWD | sudo docker login -u $DOCKER_LOGIN --password-stdin

sudo docker run  --rm=true -d  --network=host --restart always \
        -e "KONG_DATABASE=off" \
        -e "KOND_DECLARATIVE_CONFIG=/app/kong.yml" \
        -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
        -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
        -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
        -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
        -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
        --name $CONTAINER_NAME $DOCKER_IMAGE



sudo $CONTAINER_NAME $DOCKER_IMAGE

sudo docker ps -a