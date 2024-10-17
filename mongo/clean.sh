#!/bin/bash

source config.sh
docker image rm $DOCKER_USERNAME/mongo:$VERSION
docker volume prune