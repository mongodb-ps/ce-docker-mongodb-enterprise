#!/bin/bash
set -euo pipefail

# Install dependencies
yum update -y
yum install -y cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl openldap openssl xz-libs lm_sensors-libs net-snmp tar sudo

# Download automation agent
cd /tmp
if [[ "$IS_ARM" == "true" ]]; then
    AGENT_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-$AGENT_VERSION-1.rhel7_x86_64.tar.gz"
else
    AGENT_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-$AGENT_VERSION-1.amzn2_aarch64.tar.gz"
fi
curl -OL $AGENT_URL
tar -zxvf mongodb-mms-automation-agent-$AGENT_VERSION-1.rhel7_x86_64.tar.gz -C /opt/
mv /opt/mongodb-mms-automation-agent-$AGENT_VERSION-1.rhel7_x86_64 /opt/mongodb-mms-automation
groupadd -g 900 -r mongod
useradd -u 900 -r -g mongod -s /sbin/nologin -M mongod

# Create data folder
mkdir -p /data/{db,log}
chown mongod:mongod -R /data

# Clean up
yum clean all
rm -rf /var/cache/yum