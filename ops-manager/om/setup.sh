#!/bin/bash
set -euo pipefail
DEBIAN_FRONTEND=noninteractive 

# Add user/group for Ops Manager
groupadd --gid 999 --system mongodb-mms;
useradd --uid 999 --system --gid mongodb-mms --home-dir /mongodb-mms mongodb-mms;

# Install dependencies
apt update;
apt install -y openssl net-tools fontconfig curl;

# ADD instruction will automatically extract the tarball into /mongodb-mms
# Adding this line to verify the content
ls -l /mongodb-mms/

# Get JDK version from package
JAVA_VERSION=$(grep "JAVA_VERSION=" /mongodb-mms/jdk/release | cut -d'"' -f2);
MAJOR_VERSION=$(echo $JAVA_VERSION | cut -d'.' -f1);
JDK_PKG_NAME="openjdk-${MAJOR_VERSION}-jdk"

# Install system JDK
apt install -y $JDK_PKG_NAME;

# Replace JDK with system JDK
rm -rf /mongodb-mms/jdk;
ln -s /usr/lib/jvm/java-$MAJOR_VERSION-openjdk-arm64 /mongodb-mms/jdk;
chown mongodb-mms:mongodb-mms -R /mongodb-mms/;
ls -l /mongodb-mms/jdk/

# Edit Ops Manager config file
cd /mongodb-mms/conf/;
sed -i 's%mongo.mongoUri=.*%mongo.mongoUri=mongodb://'$ROOT_USER':'$ROOT_PWD'@appdb:27017/?maxPoolSize=150%' conf-mms.properties;
sed -i 's%ENC_KEY_PATH=.*%ENC_KEY_PATH=/gen.key%' mms.conf;
echo -e "
mms.centralUrl=http://host.docker.internal:$OM_MAPPING_PORT
mms.fromEmailAddr=admin@dummy.com
mms.replyToEmailAddr=admin@dummy.com
mms.adminEmailAddr=admin@dummy.com
mms.emailDaoClass=com.xgen.svc.core.dao.email.JavaEmailDao
mms.mail.transport=smtp
mms.mail.hostname=smtp.dummy.com
mms.mail.port=25
mms.ignoreInitialUiSetup=true
automation.versions.directory=/mongodb-mms/mongodb-releases
" | sudo tee -a /opt/mongodb/mms/conf/conf-mms.properties
chown mongodb-mms:mongodb-mms /gen.key;
chmod 400 /gen.key

# Set entrypoint script permissions
chmod +x /usr/local/bin/entrypoint.sh;

# Clean up
apt clean;
rm -rf /var/lib/apt/lists/*