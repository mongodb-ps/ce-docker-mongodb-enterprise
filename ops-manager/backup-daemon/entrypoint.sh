#!/bin/bash
chown mongodb-mms:mongodb-mms -R /mongodb-mms/mongodb-releases /mongodb-mms/logs
STATUS_CMD="/mongodb-mms/bin/mongodb-mms-backup-daemon status"
START_CMD="/mongodb-mms/bin/mongodb-mms-backup-daemon start"

# Start service until successfully started
until $STATUS_CMD | grep -q 'OK'; do
    $START_CMD
    echo "Restart backup daemon in 5 seconds..."
    sleep 5
done
exec tail -f /mongodb-mms/logs/daemon.log