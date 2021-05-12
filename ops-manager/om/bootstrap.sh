#!/bin/bash
DEBIAN_FRONTEND=noninteractive 
apt-get update
apt-get install -y openssl net-tools fontconfig
# Install Ops Manager
dpkg -i $PKG_NAME
rm -rf $PKG_NAME

# Ops Manager config file
cd /opt/mongodb/mms/conf/
sed -i 's%mongo.mongoUri=.*%mongo.mongoUri=mongodb://'$MONGO_INITDB_ROOT_USERNAME':'$MONGO_INITDB_ROOT_PASSWORD'@appdb:27017/?maxPoolSize=150%' conf-mms.properties
sed -i 's%ENC_KEY_PATH=.*%ENC_KEY_PATH=/opt/mongodb/mms/mongodb-releases/gen.key%' mms.conf

chmod +x /startup.sh

rm -rf /var/lib/apt/lists/*