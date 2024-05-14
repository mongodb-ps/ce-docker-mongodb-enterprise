#!/bin/bash

source ../config.sh
export PROJECT_ID="664322a90d6f3a4fd9b3be1b" # mmsGroupId in Ops Manager
export API_KEY="664327190d6f3a4fd9b3cb8dba13bfcfa42689640a672eae73fc3f20" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-107.0.6.8587-1.aarch64.amzn2.rpm" # Choose the AmazonLinux2 agent
export INSTANCES=3 # Instances you need.
