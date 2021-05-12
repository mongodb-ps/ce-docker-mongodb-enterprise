#!/bin/bash
chown mongodb-mms: -R /opt/mongodb/mms/mongodb-releases /opt/mongodb/mms/logs
/opt/mongodb/mms/bin/mongodb-mms start
tail -f /opt/mongodb/mms/logs/mms0.log