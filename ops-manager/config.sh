#!/bin/bash

source ../config.sh
export MONGODB_VERSION=4.4 # AppDB MongoDB version
export OM_URL=https://downloads.mongodb.com/on-prem-mms/deb/mongodb-mms_4.4.12.100.20210503T1412Z-1_x86_64.deb # Ops Manager binary download URL
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
export OM_VERSION=`awk -F '_' '{print $2}' <<< $PKG_NAME`
