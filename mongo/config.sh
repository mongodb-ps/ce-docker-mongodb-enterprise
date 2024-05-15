#!/bin/bash

source ../config.sh
export OM_URL="http://host.docker.internal:8080" # mmsBaseUrl in Ops Manager
export AA_URL="$OM_URL/download/agent/automation/mongodb-mms-automation-agent-manager-107.0.6.8587-1.aarch64.amzn2.rpm" # Choose the AmazonLinux2 agent
export INSTANCES=3 # Instances you need.
