#!/bin/bash
chown mongod:mongod -R /data
chown mongod:mongod -R /var/lib/mongodb-mms-automation
chown mongod:mongod -R /var/log/mongodb-mms-automation
sudo -u mongod /opt/mongodb-mms-automation/mongodb-mms-automation-agent -mmsBaseUrl $OM_URL -mmsGroupId $PROJECT_ID -mmsApiKey $AGENT_API_KEY