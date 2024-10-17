#!/bin/bash

cd om

if [ -z "`docker images -q $DOCKER_USERNAME/ops-manager:$OM_VERSION`" ]; then
    # image doesn't exist, build one.
    echo "Building MongoDB Ops Manager image."
    if [ -z $OM_URL ] || [ -z $PKG_NAME ] || [ -z $OM_VERSION ]; then
        echo "Please provide correct MongoDB Ops Manager URL in OM_URL."
        exit 127
    else
        echo "Going to build Ops Manager image: $PKG_NAME"
        echo "Version: $OM_VERSION"
    fi
    if [ -f "$PKG_NAME" ]; then
        echo "$PKG_NAME exists. Skip downloading."
    else
        echo "Downloading Ops Manager: $OM_URL"
        curl -O $OM_URL
    fi
    docker build --build-arg MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME \
        --build-arg MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD \
        --build-arg PKG_NAME=$PKG_NAME \
        --build-arg http_proxy=$_HTTP_PROXY \
        --build-arg https_proxy=$_HTTPS_PROXY \
        --progress=plain \
        ./ -t $DOCKER_USERNAME/ops-manager:$OM_VERSION
else
    echo "MongoDB Ops Manager image already exists. Skip building."
fi
cd ../