#!/bin/bash

source ../config.sh
export PROJECT_ID="64135d916d1e4f2360663de6" # mmsGroupId in Ops Manager
export API_KEY="64135dae6d1e4f2360663e4c3e206c4356bd343aa3e6aeb14f8b7e93" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-12.0.18.7668-1.aarch64.amzn2.rpm"
export INSTANCES=3