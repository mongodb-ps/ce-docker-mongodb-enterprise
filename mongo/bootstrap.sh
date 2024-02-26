#!/bin/bash

# Enterprise dependencies
apt-get update; \
apt-get install -y libcurl4 libldap-2.5-0 libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit snmp openssl curl; \
echo "The following parameters are used to build mongo image: $OM_URL,$PROJECT_ID,$API_KEY"; \
unset http_proxy; \
unset https_proxy; \
curl -OL $AA_URL; \
# dkpg thinks aarch64 is different from arm64. This will fix the problem.
dpkg --add-architecture aarch64; \
dpkg -i *.deb; \
sed -i "s%mmsGroupId=.*%mmsGroupId=$PROJECT_ID%" /etc/mongodb-mms/automation-agent.config; \
sed -i "s%mmsApiKey=.*%mmsApiKey=$API_KEY%" /etc/mongodb-mms/automation-agent.config; \
sed -i "s%mmsBaseUrl=.*%mmsBaseUrl=$OM_URL%" /etc/mongodb-mms/automation-agent.config; \
mkdir -p /data/{db,log}; \
chown mongodb:mongodb -R /data
rm -rf /var/lib/apt/lists/* *.deb