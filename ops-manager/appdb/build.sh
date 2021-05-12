#!/bin/bash

cd appdb
if [ -z `docker images -q $DOCKER_USERNAME/mongo-enterprise:$MONGODB_VERSION` ]; then
    # image doesn't exist, build one.
    echo "Building MongoDB Enterprise image."
    # curl -Ol --remote-name-all https://raw.githubusercontent.com/docker-library/mongo/master/$MONGODB_VERSION/{Dockerfile,docker-entrypoint.sh}
    # chmod +x docker-entrypoint.sh
    docker build --build-arg MONGO_PACKAGE=mongodb-enterprise \
        --build-arg MONGO_REPO=repo.mongodb.com \
        --build-arg http_proxy=$_HTTP_PROXY \
        --build-arg https_proxy=$_HTTPS_PROXY \
        -t $DOCKER_USERNAME/mongo-enterprise:$MONGODB_VERSION .
else
    echo "MongoDB Enterprise image already exists. Skip building."
fi
cd ../