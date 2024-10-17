#!/bin/bash

# Enterprise dependencies
yum update -y; \
yum install -y cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl openldap openssl xz-libs lm_sensors-libs net-snmp; \
echo "The following parameters are used to build mongo image: $OM_URL,$PROJECT_ID,$API_KEY"; \
unset http_proxy; \
unset https_proxy; \
curl -OL $AA_URL; \
ls -l
rpm -ivh *.rpm; \
sed -i "s%mmsGroupId=.*%mmsGroupId=$PROJECT_ID%" /etc/mongodb-mms/automation-agent.config; \
sed -i "s%mmsApiKey=.*%mmsApiKey=$API_KEY%" /etc/mongodb-mms/automation-agent.config; \
sed -i "s%mmsBaseUrl=.*%mmsBaseUrl=$OM_URL%" /etc/mongodb-mms/automation-agent.config; \
mkdir -p /data/{db,log}; \
chown mongod:mongod -R /data; \
yum clean all; \
rm -rf /var/cache/yum; \