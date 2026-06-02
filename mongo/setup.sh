#!/bin/bash
set -euo pipefail

# Install dependencies
yum update -y
yum install -y cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl openldap openssl xz-libs lm_sensors-libs net-snmp tar sudo

# Download automation agent
cd /tmp
if [[ "$IS_ARM" == "true" ]]; then
    AGENT_PKG_NAME="mongodb-mms-automation-agent-$AGENT_VERSION-1.amzn2_aarch64"
else
    AGENT_PKG_NAME="mongodb-mms-automation-agent-$AGENT_VERSION-1.linux_x86_64"
fi
AGENT_URL="$OM_URL/download/agent/automation/$AGENT_PKG_NAME.tar.gz"
curl -OL $AGENT_URL
tar -zxvf $AGENT_PKG_NAME.tar.gz -C /opt/
mv /opt/$AGENT_PKG_NAME /opt/mongodb-mms-automation
groupadd -g 900 -r mongod
useradd -u 900 -r -g mongod -s /sbin/nologin -M mongod

# Create data folder
mkdir -p /data/{db,log}
mkdir -p /var/lib/mongodb-mms-automation
mkdir -p /var/log/mongodb-mms-automation

# Clean up
yum clean all
rm -rf /var/cache/yum