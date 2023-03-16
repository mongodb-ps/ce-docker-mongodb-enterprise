#!/bin/bash

source ../config.sh
export PROJECT_ID="640f2603721d954bf71eb3de" # mmsGroupId in Ops Manager
export API_KEY="6412d35143ff9e07242798d9ea9023db55fcf0ed8fcd346a9a88d6e1" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL"/download/agent/automation/mongodb-mms-automation-agent-manager-12.0.18.7668-1.aarch64.amzn2.rpm