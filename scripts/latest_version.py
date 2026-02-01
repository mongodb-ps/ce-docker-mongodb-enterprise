import sys
from om_api import api_get_anonymous, OM_URL

VERSION_MANIFEST_URL_GET = f"{OM_URL}/api/public/v1.0/unauth/versionManifest"
version_manifest_response = api_get_anonymous(VERSION_MANIFEST_URL_GET, {})
if version_manifest_response.status_code != 200:
    print(f"Failed to get version manifest: {version_manifest_response.text}")
    sys.exit(1)
version_manifest = version_manifest_response.json()
versions = version_manifest.get("versions", [])
latest_version = max([v["name"] for v in versions])
print(latest_version)
