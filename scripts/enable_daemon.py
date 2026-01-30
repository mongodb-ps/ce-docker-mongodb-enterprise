"""Enable the daemon on specified hosts using the automation config API."""
import sys
import os
from om_api import api_get, api_put

OM_URL = "http://host.docker.internal:8080"
HEADDB_PATH = "/headDB/"
public_key = os.environ["PUBLIC_KEY"]
private_key = os.environ["PRIVATE_KEY"]

DAEMON_GET_URL = f"{OM_URL}/api/public/v1.0/admin/backup/daemon/configs/"
daemon_response = api_get(DAEMON_GET_URL, public_key, private_key, {})
daemons = daemon_response.json().get("results", [])
for daemon in daemons:
    daemon_id = daemon["id"]
    machine = daemon["machine"]
    machine["headRootDirectory"] = HEADDB_PATH
    if daemon["configured"]:
        print(f"Daemon {daemon_id}/{machine['machine']} is already enabled.")
        continue
    print(f"Enabling daemon {daemon_id}/{machine['machine']}...")
    DAEMON_PUT_URL = f"{OM_URL}/api/public/v1.0/admin/backup/daemon/configs/{machine['machine']}/"
    daemon_response = api_put(DAEMON_PUT_URL, public_key, private_key, {
        "configured": True,
        "id": daemon_id,
        "machine": machine
    })
    if daemon_response.status_code != 200:
        print(f"Failed to enable daemon {daemon_id}/{machine['machine']}: {daemon_response.text}")
    else:
        print(f"Daemon {daemon_id}/{machine['machine']} enabled successfully.")
sys.exit(0)
