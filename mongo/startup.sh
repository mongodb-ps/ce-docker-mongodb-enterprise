#!/bin/bash
mkdir -p /var/log/mongodb-mms-automation/
chown mongodb:mongodb /var/log/mongodb-mms-automation/
chown mongodb:mongodb /data/db /data/log
/opt/mongodb-mms-automation/bin/mongodb-mms-automation-agent -f /etc/mongodb-mms/automation-agent.config