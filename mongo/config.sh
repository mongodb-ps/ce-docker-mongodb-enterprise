#!/bin/bash

source ../config.sh
export PROJECT_ID="65a79e743c03e801e587d697" # mmsGroupId in Ops Manager
export API_KEY="65a79f4a3c03e801e587d898c0e5cfac3086d6e0f852c94bdd2379aa" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-12.0.28.7763-1.aarch64.amzn2.rpm"
export INSTANCES=3
