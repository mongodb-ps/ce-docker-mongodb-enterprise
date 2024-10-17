#!/bin/bash

source config.sh
docker image rm $DOCKER_USERNAME/mongo:$OM_VERSION
docker volume prune