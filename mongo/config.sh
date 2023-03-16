#!/bin/bash

source ../config.sh
export PROJECT_ID="641318f6ece048144781e300" # mmsGroupId in Ops Manager
export API_KEY="641319b3ece048144781e388baa8a2a991f875355d62e3ca20aa4d7b" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-12.0.18.7668-1.aarch64.amzn2.rpm"
export INSTANCES=3