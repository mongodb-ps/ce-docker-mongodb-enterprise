"""Create oplog store for OM if not exists."""
import os
import sys
from om_api import api_post, api_get

public_key = os.environ["PUBLIC_KEY"]
private_key = os.environ["PRIVATE_KEY"]
root_user = os.environ["ROOT_USER"]
root_pwd = os.environ["ROOT_PWD"]
OM_URL = "http://host.docker.internal:8080"
FS_STORE_ID = "fs_store"
FS_STORE_URL_POST = f"{OM_URL}/api/public/v1.0/admin/backup/snapshot/fileSystemConfigs"
FS_STORE_URL_GET = f"{FS_STORE_URL_POST}/{FS_STORE_ID}"
FS_STORE_PATH = "/snapshots/"

res = api_get(FS_STORE_URL_GET, public_key, private_key, {})
if res.status_code == 200:
    print(f"File system store {FS_STORE_ID} already configured.")
else:
    data = {
        "id": FS_STORE_ID,
        "storePath": FS_STORE_PATH,
        "assignmentEnabled": True,
        "wtCompressionSetting": "NONE",
        "mmapv1CompressionSetting": "GZIP"
    }
    res = api_post(FS_STORE_URL_POST, public_key, private_key, data)
    if res.status_code >= 200 and res.status_code < 300:
        print(f"Successfully created file system store {FS_STORE_ID}.")
    else:
        print(f"Failed to create file system store {FS_STORE_ID}: {res.text}")
        sys.exit(1)

OPLOG_STORE_ID = "oplog_store"
OPLOG_STORE_URL_POST = f"{OM_URL}/api/public/v1.0/admin/backup/oplog/mongoConfigs"
OPLOG_STORE_URL_GET = f"{OPLOG_STORE_URL_POST}/{OPLOG_STORE_ID}"
res = api_get(OPLOG_STORE_URL_GET, public_key, private_key, {})
if res.status_code == 200:
    print(f"Oplog store {OPLOG_STORE_ID} already configured.")
else:
    data = {
        "id": OPLOG_STORE_ID,
        "uri": f"mongodb://{root_user}:{root_pwd}@appdb:27017/admin",
        "assignmentEnabled": True,
    }
    res = api_post(OPLOG_STORE_URL_POST, public_key, private_key, data)
    if res.status_code >= 200 and res.status_code < 300:
        print(f"Successfully created oplog store {OPLOG_STORE_ID}.")
    else:
        print(f"Failed to create oplog store {OPLOG_STORE_ID}: {res.text}")
        sys.exit(1)