#!/bin/bash

# Enterprise dependencies
apt-get update
apt-get install -y curl libcurl4 libgssapi-krb5-2 libldap-2.4-2 libwrap0 libsasl2-2 snmp openssl liblzma5

echo "The following parameters are used: $OM_URL,$ORG_ID,$API_KEY"
unset http_proxy
unset https_proxy
curl -O $OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager_10.14.16.6437-1_amd64.ubuntu1604.deb
dpkg -i mongodb-mms-automation-agent-manager_10.14.16.6437-1_amd64.ubuntu1604.deb
sed -i "s%mmsGroupId=.*%mmsGroupId=$ORG_ID%" /etc/mongodb-mms/automation-agent.config
sed -i "s%mmsApiKey=.*%mmsApiKey=$API_KEY%" /etc/mongodb-mms/automation-agent.config
sed -i "s%mmsBaseUrl=.*%mmsBaseUrl=$OM_URL%" /etc/mongodb-mms/automation-agent.config
mkdir -p /data/{db,log}
chown mongodb:mongodb -R /data

rm -rf /var/lib/apt/lists/*