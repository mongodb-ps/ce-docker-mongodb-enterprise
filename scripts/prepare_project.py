"""Prepare for guest VM."""
import os
import json
import sys
from om_api import api_get, api_post

URL_PREFIX = "http://host.docker.internal:8080/api/public/v1.0"
ORG_NAME = "MongoDB Docker"
PROJECT_NAME = "MongoDB"
public_key = os.environ["PUBLIC_KEY"]
private_key = os.environ["PRIVATE_KEY"]

# Create organization if it does not exist.
ORG_URL = f"{URL_PREFIX}/orgs"
orgs_response = api_get(ORG_URL, public_key, private_key, {})
if orgs_response.status_code != 200:
    sys.exit(1)

orgs = orgs_response.json().get("results", [])
org_id = None
for org in orgs:
    if org["name"] == ORG_NAME and org["isDeleted"] is False:
        org_id = org["id"]
if not org_id:
    new_org_response = api_post(ORG_URL, public_key, private_key, {"name": ORG_NAME})
    org_id = new_org_response.json().get("id")

# Create project if it does not exist.
PROJECT_URL = f"{URL_PREFIX}/groups"
PROJECT_GET_URL = f"{URL_PREFIX}/groups/byName/{PROJECT_NAME}"
project_response = api_get(PROJECT_GET_URL, public_key, private_key, {})
if project_response.status_code != 200:
    project_response = api_post(PROJECT_URL, public_key, private_key, {
        "name": PROJECT_NAME,
        "orgId": org_id
    })
project = project_response.json()
project_id = project.get("id", None)
agent_key = project.get("agentApiKey", None)

if not agent_key:
    # Create agent API key for the project.
    AGENT_URL = f"{URL_PREFIX}/groups/{project_id}/agentapikeys"
    agent_key_response = api_post(AGENT_URL, public_key, private_key, {
        "desc": "API key for automation agents."
    })
    agent_key = agent_key_response.json().get("key")

AUTOMATION_URL = f"{URL_PREFIX}/softwareComponents/versions"
automation_response = api_get(AUTOMATION_URL, public_key, private_key, {})
agent_version = automation_response.json().get("automationVersion")

print(json.dumps({
    "org_id": org_id,
    "project_id": project_id,
    "agent_api_key": agent_key,
    "agent_version": agent_version
}))
