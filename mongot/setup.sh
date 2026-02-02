#!/bin/bash
set -euo pipefail

groupadd --gid 999 --system mongot;
useradd --uid 999 --system --gid mongot --home-dir /home/mongot mongot;
mkdir -p /home/mongot;
chown mongot:mongot /home/mongot;

cat > /home/mongot/mongot.conf <<EOF
syncSource:
   replicaSet:
      hostAndPort: mongo_2_1:27017
      username: ${MONGOT_USER}
      passwordFile: /home/mongot/passwordFile
      tls: false
      readPreference: primaryPreferred
storage:
   dataPath: ${MONGOT_DATAPATH}
server:
   grpc:
      address: "0.0.0.0:27028"
      tls:
         mode: "disabled"
metrics:
   enabled: true
   address: "0.0.0.0:9946"
healthCheck:
   address: "0.0.0.0:8080"
logging:
   verbosity: INFO
EOF
