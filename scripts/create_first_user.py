import os
import sys
from om_api import api_post_anonymous, OM_URL

public_key = os.getenv("PUBLIC_KEY", None)
private_key = os.getenv("PRIVATE_KEY", None)
admin_email = os.getenv("OM_ADMIN_EMAIL", "admin@mongodb.com")
admin_pwd = os.getenv("OM_ADMIN_PWD", None)
first_name = os.getenv("OM_ADMIN_FIRSTNAME", "Admin")
last_name = os.getenv("OM_ADMIN_LASTNAME", "User")

WHITELIST_IPS = ["172.18.0.1", "172.17.0.1", "192.168.65.1"]
WHITELISTS = "&".join(f"whitelist={ip}" for ip in WHITELIST_IPS)
FIRST_USER_URL = f"{OM_URL}/api/public/v1.0/unauth/users?{WHITELISTS}"

if public_key is not None and private_key is not None:
    print("Public and Private keys are already set. Skipping first user creation.")
    sys.exit(0)

data = {
    "username": admin_email,
    "password": admin_pwd,
    "firstName": first_name,
    "lastName": last_name,
}
res = api_post_anonymous(FIRST_USER_URL, data)
if res.status_code < 200 or res.status_code >= 300:
    print(f"Failed to create first admin user. Code: {res.status_code}, Response: {res.text}")
    sys.exit(1)
print("First admin user created successfully.")

resp_json = res.json()
public_key = resp_json.get("programmaticApiKey", {}).get("publicKey", None)
private_key = resp_json.get("programmaticApiKey", {}).get("privateKey", None)
with open("config", "a", encoding="utf-8") as f:
    f.write(f"export PUBLIC_KEY={public_key}\n")
    f.write(f"export PRIVATE_KEY={private_key}\n")
