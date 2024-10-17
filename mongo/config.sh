#!/bin/bash

source ../config.sh
export PROJECT_ID="6710bee10e18e409aced5e29" # mmsGroupId in Ops Manager
export API_KEY="6710c10e0e18e409aced64e5ccc43080473afefd0c3dff321cd2f8f2" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-108.0.0.8694-1.aarch64.amzn2.rpm" # Choose the AmazonLinux2 agent
export INSTANCES=3 # Instances you need.
export VERSION=8.0
export BASE_DBPATH=/Users/yaoxing.zhang/Workspace/MongoDB/om_mongo
