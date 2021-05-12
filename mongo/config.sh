#!/bin/bash

source ../config.sh
export ORG_ID="5fb5422be03dd800c4f66c17" # mmsGroupId in Ops Manager
export API_KEY="5fbb1092e03dd800c4fb504c061d069f20dd16aba9d803e62d93c36e" # mmsApiKey in Ops Manager
export OM_URL="http://localhost:8080" # mmsBaseUrl in Ops Manager
export DB_PATH="/home/docker/data/deployments/db" # dbPath for MongoDB
export LOG_PATH="/home/docker/data/deployments/log" # logPath for MongoDB