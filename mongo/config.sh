#!/bin/bash

source ../config.sh
export PROJECT_ID="65dc76bbd6573901883838a2" # mmsGroupId in Ops Manager
export API_KEY="65dc79ded657390188384157a68b0f8a8088d1901e92b0dff45b9d05" # mmsApiKey in Ops Manager
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-107.0.2.8531-1.aarch64.amzn2.rpm" # Choose the AmazonLinux2 agent
export INSTANCES=3 # Instances you need.
