#!/bin/bash

# Enterprise dependencies
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum update -y
yum install -y cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs net-snmp openldap openssl xz-libs

echo "The following parameters are used: $OM_URL,$PROJECT_ID,$API_KEY"
unset http_proxy
unset https_proxy
curl -OL $AA_URL
rpm -ivh *.rpm
sed -i "s%mmsGroupId=.*%mmsGroupId=$PROJECT_ID%" /etc/mongodb-mms/automation-agent.config
sed -i "s%mmsApiKey=.*%mmsApiKey=$API_KEY%" /etc/mongodb-mms/automation-agent.config
sed -i "s%mmsBaseUrl=.*%mmsBaseUrl=$OM_URL%" /etc/mongodb-mms/automation-agent.config
mkdir -p /data/{db,log}
chown mongod:mongod -R /data