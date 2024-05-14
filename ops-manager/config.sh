#!/bin/bash

source ../config.sh
export MONGODB_VERSION=7.0 # AppDB MongoDB version
export OM_URL=https://downloads.mongodb.com/on-prem-mms/tar/mongodb-mms-7.0.6.500.20240509T1453Z.tar.gz
export MONGO_INITDB_ROOT_USERNAME=root # Initial admin account name for AppDB.
export MONGO_INITDB_ROOT_PASSWORD=V4ei2VZrIuHY # Initial admin password. DO CHANGE THE PASSWORD!
export DB_VOLUME=~/Workspace/MongoDB/appdb # Host folder for storing AppDB data files
export OM_MONGO_RELEASES=~/Workspace/MongoDB/mongodb-releases # Host folder for storing Ops Manager MongoDB releases.
export OM_SNAPSHOTS=~/Workspace/MongoDB/snapshots/ # Host folder for storing backup snapshots
export OM_HEADDB=~/Workspace/MongoDB/headDB/ # Host folder for storing headDB
export OM_LOGS=~/Workspace/MongoDB/om_logs # Host folder for storing Ops Manager logs

# extract OM package name and version from OM_URL
# DO NOT MODIFY
export PKG_NAME=`awk -F '/' '{print $NF}' <<< $OM_URL`
OM_VERSION_TMP=`awk -F '-' '{print $3}' <<< $PKG_NAME`
export OM_VERSION=`awk -F '.' '{print $1"."$2"."$3}' <<< $OM_VERSION_TMP`
