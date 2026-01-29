#!/bin/bash
chown mongodb-mms:mongodb-mms -R /mongodb-mms/mongodb-releases /mongodb-mms/logs

/mongodb-mms/bin/mongodb-mms start_backup_daemon
exec tail -f /mongodb-mms/logs/daemon.log