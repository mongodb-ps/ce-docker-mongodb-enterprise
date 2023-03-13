#!/bin/bash
chown mongodb-mms:mongodb-mms -R /mongodb-mms/mongodb-releases /mongodb-mms/logs
/mongodb-mms/bin/mongodb-mms start
tail -f /mongodb-mms/logs/mms0.log