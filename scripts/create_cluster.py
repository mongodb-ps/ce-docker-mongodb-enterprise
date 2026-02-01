"""Prepare backing replica set"""

import os
import sys
from time import sleep
from om_api import api_get, api_put, OM_URL

PROJECT_IDX = int(os.environ["PROJECT_IDX"])
PROJECT_ID = os.environ["PROJECT_ID"]
PUBLIC_KEY = os.environ["PUBLIC_KEY"]
PRIVATE_KEY = os.environ["PRIVATE_KEY"]
ROOT_USER = os.environ["ROOT_USER"]
ROOT_PWD = os.environ["ROOT_PWD"]
MONGOT_USER = os.environ["MONGOT_USER"]
MONGOT_PWD = os.environ["MONGOT_PWD"]
KEY_FILE_CONTENT = os.environ["KEY_FILE_CONTENT"]
AUTO_PWD = os.environ["AUTO_PWD"]
RS = os.environ["RS_NAME"]
HOST_COUNT = int(os.environ["HOST_COUNT"])
LATEST_VERSION = os.environ["LATEST_VERSION"]
FCV = f"{LATEST_VERSION.split('.')[0]}.{LATEST_VERSION.split('.')[1]}"
HOSTS = [f"mongo_{PROJECT_IDX}_{i + 1}" for i in range(HOST_COUNT)]

AUTOMATION_URL = f"{OM_URL}/api/public/v1.0/groups/{PROJECT_ID}/automationConfig"
auto_config_response = api_get(AUTOMATION_URL, PUBLIC_KEY, PRIVATE_KEY, {})
auto_config = auto_config_response.json()

auto_config["auth"] = {
    "authoritativeSet": True,
    "autoAuthMechanism": "MONGODB-CR",
    "autoAuthMechanisms": ["MONGODB-CR", "SCRAM-SHA-256"],
    "autoAuthRestrictions": [],
    "autoPwd": AUTO_PWD,
    "autoUser": "mms-automation",
    "deploymentAuthMechanisms": ["MONGODB-CR", "SCRAM-SHA-256"],
    "disabled": False,
    "key": KEY_FILE_CONTENT,
    "keyfile": "/var/lib/mongodb-mms-automation/keyfile",
    "keyfileWindows": "%SystemDrive%\\MMSAutomation\\versions\\keyfile",
    "usersDeleted": [],
    "usersWanted": [
        {
            "authenticationRestrictions": [],
            "db": "admin",
            "mechanisms": ["SCRAM-SHA-1", "SCRAM-SHA-256"],
            "roles": [{"db": "admin", "role": "root"}],
            "initPwd": f"{ROOT_PWD}",
            "user": f"{ROOT_USER}",
        },
        {
            "authenticationRestrictions": [],
            "db": "admin",
            "mechanisms": ["SCRAM-SHA-1", "SCRAM-SHA-256"],
            "roles": [{"db": "admin", "role": "searchCoordinator"}],
            "initPwd": f"{MONGOT_PWD}",
            "user": f"{MONGOT_USER}",
        }
    ],
}
# Remove existing replica set config if exists
all_rs = [
    rs_cfg for rs_cfg in auto_config.get("replicaSets", []) if rs_cfg["_id"] != RS
]
all_rs.append(
    {
        "_id": f"{RS}",
        "members": [
            {
                "_id": i,
                "arbiterOnly": False,
                "buildIndexes": True,
                "hidden": False,
                "host": f"{RS}_{i}",
                "priority": 1.0,
                "secondaryDelaySecs": 0,
                "votes": 1,
            }
            for i in range(len(HOSTS))
        ],
        "protocolVersion": "1",
        "settings": {},
    }
)
auto_config["replicaSets"] = all_rs
# Remove existing processes for the replica set
auto_config["processes"] = [
    proc
    for proc in auto_config.get("processes", [])
    if not proc["name"].startswith(f"{RS}_")
]
auto_config["processes"].extend(
    [
        {
            "args2_6": {
                "net": {"port": 27017},
                "replication": {"replSetName": f"{RS}"},
                "storage": {"dbPath": "/data/db"},
                "systemLog": {"destination": "file", "path": "/data/log/mongodb.log"},
                "setParameter": {
                    "searchIndexManagementHostAndPort": "mongot:27028",
                    "mongotHost": "mongot:27028",
                    "skipAuthenticationToSearchIndexManagementServer": False,
                    "useGrpcForSearch": True,
                }
            },
            "auditLogRotate": {"sizeThresholdMB": 1000.0, "timeThresholdHrs": 24},
            "authSchemaVersion": 5,
            "disabled": False,
            "featureCompatibilityVersion": f"{FCV}",
            "horizons": {},
            "hostname": f"{host}",
            "logRotate": {"sizeThresholdMB": 1000.0, "timeThresholdHrs": 24},
            "manualMode": False,
            "name": f"{RS}_{i}",
            "processType": "mongod",
            "version": f"{LATEST_VERSION}",
        }
        for i, host in enumerate(HOSTS)
    ]
)

# Remove existing backup and monitoring versions for the hosts
auto_config["backupVersions"] = [
    bv
    for bv in auto_config.get("backupVersions", [])
    if bv["hostname"] not in HOSTS
]
auto_config["backupVersions"].extend(
    [
        {
            "baseUrl": f"{OM_URL}",
            "hostname": f"{host}",
            "logPath": "/var/log/mongodb-mms-automation/backup-agent.log",
            "logRotate": {"sizeThresholdMB": 1000.0, "timeThresholdHrs": 24},
            "name": "backup agent",
        }
        for host in HOSTS
    ]
)

# Remove existing monitoring versions for the hosts
auto_config["monitoringVersions"] = [
    mv
    for mv in auto_config.get("monitoringVersions", [])
    if mv["hostname"] not in HOSTS
]
auto_config["monitoringVersions"].extend(
    [
        {
            "baseUrl": f"{OM_URL}",
            "hostname": f"{host}",
            "logPath": "/var/log/mongodb-mms-automation/monitoring-agent.log",
            "logRotate": {"sizeThresholdMB": 1000.0, "timeThresholdHrs": 24},
            "name": "monitoring agent",
        }
        for host in HOSTS
    ]
)
response = api_put(AUTOMATION_URL, PUBLIC_KEY, PRIVATE_KEY, auto_config)
if response.status_code != 200:
    print(f"Failed to update automation config: {response.text}")
    sys.exit(1)

# Wait for the automation config to be applied
STATUS_URL = f"{OM_URL}/api/public/v1.0/groups/{PROJECT_ID}/automationStatus"
while True:
    status_response = api_get(STATUS_URL, PUBLIC_KEY, PRIVATE_KEY, {})
    status = status_response.json()
    proc_statuses = [
        s["lastGoalVersionAchieved"]
        for s in status.get("processes", [])
        if s["name"].startswith(f"{RS}_")
    ]
    goal_version = status.get("goalVersion")
    if all(v >= goal_version for v in proc_statuses):
        break
    print("Waiting for automation config to be applied...")
    print(f"Goal version: {goal_version}, Current process versions: {proc_statuses}")
    sleep(10)
print("Automation config applied.")
