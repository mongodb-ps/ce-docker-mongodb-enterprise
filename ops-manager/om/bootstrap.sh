#!/bin/bash
DEBIAN_FRONTEND=noninteractive 
apt-get update; \
apt-get install -y openssl net-tools fontconfig; \
apt update; \
apt install -y openjdk-17-jdk; \
# Install Ops Manager
tar -zxvf $PKG_NAME; \
rm -rf /mongodb-mms/jdk; \
ln -s /usr/lib/jvm/java-17-openjdk-arm64 /mongodb-mms/jdk; \
chown mongodb-mms:mongodb-mms -R /mongodb-mms/; \
rm -rf $PKG_NAME; \
# Ops Manager config file
cd /mongodb-mms/conf/; \
sed -i 's%mongo.mongoUri=.*%mongo.mongoUri=mongodb://'$MONGO_INITDB_ROOT_USERNAME':'$MONGO_INITDB_ROOT_PASSWORD'@appdb:27017/?maxPoolSize=150%' conf-mms.properties; \
sed -i 's%ENC_KEY_PATH=.*%ENC_KEY_PATH=/mongodb-mms/mongodb-releases/gen.key%' mms.conf; \
chmod +x /startup.sh; \
rm -rf /var/lib/apt/lists/*