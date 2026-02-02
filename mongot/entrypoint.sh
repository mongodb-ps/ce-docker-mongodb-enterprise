#!/bin/bash
set -euo pipefail

MONGOT_BIN_PATH="/mongot-community/mongot"
echo -n $MONGOT_PWD > /home/mongot/passwordFile
chown mongot:mongot /home/mongot/passwordFile
chmod 400 /home/mongot/passwordFile

sed -i "s%hostAndPort: .*%hostAndPort: ${MONGOD_HOSTS}%" /home/mongot/mongot.conf

$MONGOT_BIN_PATH --config /home/mongot/mongot.conf --internalListAllIndexesForTesting=true
