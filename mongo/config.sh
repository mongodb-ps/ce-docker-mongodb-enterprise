#!/bin/bash

source ../config.sh
export PROJECT_ID="65aa42b50bcd081ed446e6df" # mmsGroupId in Ops Manager
export API_KEY="65b225b81f8e74441a8bebd61bd12b6ea9da8659a58092dc7867b9b0" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-12.0.28.7763-1.aarch64.amzn2.rpm"
export INSTANCES=3
