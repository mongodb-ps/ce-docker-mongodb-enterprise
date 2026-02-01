"""Prepare for guest VM."""
import os
import sys
from om_api import api_get, api_post, OM_URL

URL_PREFIX = f"{OM_URL}/api/public/v1.0"
public_key = os.environ["PUBLIC_KEY"]
private_key = os.environ["PRIVATE_KEY"]
ORG_NAME = sys.argv[1]
PROJECT_NAME = sys.argv[2]
INDEX = sys.argv[3]

# Create organization if it does not exist.
ORG_URL = f"{URL_PREFIX}/orgs"
orgs_response = api_get(ORG_URL, public_key, private_key, {})
if orgs_response.status_code != 200:
    sys.exit(1)

orgs = orgs_response.json().get("results", [])
ORG_ID = None
for org in orgs:
    if org["name"] == ORG_NAME and org["isDeleted"] is False:
        ORG_ID = org["id"]
        print(
            f"Found existing organization: {ORG_NAME} ({ORG_ID}). Skipping organization creation.",
            file=sys.stderr
        )
if not ORG_ID:
    new_org_response = api_post(ORG_URL, public_key, private_key, {"name": ORG_NAME})
    ORG_ID = new_org_response.json().get("id")
    print(f"Created organization: {ORG_NAME} ({ORG_ID}).")
with open("config", "a", encoding="utf-8") as config_file:
    config_file.write(f"export ORG_ID_{INDEX}={ORG_ID}\n")

# Create project if it does not exist.
PROJECT_URL = f"{URL_PREFIX}/groups"
PROJECT_GET_URL = f"{URL_PREFIX}/groups/byName/{PROJECT_NAME}"
project_response = api_get(PROJECT_GET_URL, public_key, private_key, {})
if project_response.status_code == 200:
    print(f"Found existing project: {PROJECT_NAME}. Skipping project creation.", file=sys.stderr)
    sys.exit(0)

project_response = api_post(PROJECT_URL, public_key, private_key, {
    "name": PROJECT_NAME,
    "orgId": ORG_ID
})
project = project_response.json()
project_id = project.get("id", None)
agent_key = project.get("agentApiKey", None)
print(f"Created project: {PROJECT_NAME} ({project_id}).")

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

with open("config", "a", encoding="utf-8") as config_file:
    config_file.write(f"export PROJECT_ID_{INDEX}={project_id}\n")
    config_file.write(f"export AGENT_API_KEY_{INDEX}={agent_key}\n")
    config_file.write(f"export AGENT_VERSION_{INDEX}={agent_version}\n")
