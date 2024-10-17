#!/bin/bash

source ./config.sh

if [ -z "`docker images -q $DOCKER_USERNAME/mongo`" ]; then
    if [ -z $PROJECT_ID ] || [ -z $API_KEY ] || [ -z $OM_URL ]; then
        echo "Please provide necessary parameters to proceed. Check config.sh."
        exit 127
    fi

    docker build \
            --build-arg OM_URL=$OM_URL \
            --build-arg API_KEY=$API_KEY \
            --build-arg PROJECT_ID=$PROJECT_ID \
            --build-arg AA_URL=$AA_URL \
            --build-arg http_proxy=$_HTTP_PROXY \
            --build-arg https_proxy=$_HTTPS_PROXY \
            --progress=plain \
            ./ -t $DOCKER_USERNAME/mongo:$VERSION
else
    echo "MongoDB image already exists. Skip building."
fi