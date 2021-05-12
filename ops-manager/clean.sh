#!/bin/bash

source config.sh
docker image rm $DOCKER_USERNAME/mongo-enterprise:$MONGODB_VERSION
docker image rm $DOCKER_USERNAME/ops-manager:$OM_VERSION