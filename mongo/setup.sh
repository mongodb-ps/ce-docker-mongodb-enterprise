#!/bin/bash
set -euo pipefail

# Install dependencies
yum update -y
yum install -y cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs openldap openssl xz-libs sudo tar hostname procps-ng

# Download automation agent
cd /tmp
if [[ "$IS_ARM" == "true" ]]; then
    # The aarch64 platform suffix changed in Ops Manager 9.0:
    # "amzn2_aarch64" (<= 8.0) -> "linux_aarch64" (>= 9.0).
    # Try the new name first and fall back to the old one for compatibility.
    AGENT_PKG_SUFFIXES="linux_aarch64 amzn2_aarch64"
else
    AGENT_PKG_SUFFIXES="linux_x86_64"
fi

AGENT_PKG_NAME=""
for AGENT_PKG_SUFFIX in $AGENT_PKG_SUFFIXES; do
    AGENT_PKG_NAME="mongodb-mms-automation-agent-$AGENT_VERSION-1.$AGENT_PKG_SUFFIX"
    AGENT_URL="$OM_URL/download/agent/automation/$AGENT_PKG_NAME.tar.gz"
    echo "Trying automation agent package: $AGENT_PKG_NAME.tar.gz"
    # -f makes curl fail on HTTP errors, and the archive is validated so that an
    # error page is not mistaken for a package that actually exists.
    if curl -fsSL -o "$AGENT_PKG_NAME.tar.gz" "$AGENT_URL" \
        && tar -tzf "$AGENT_PKG_NAME.tar.gz" >/dev/null 2>&1; then
        break
    fi
    echo "Package $AGENT_PKG_NAME.tar.gz is not available."
    rm -f "$AGENT_PKG_NAME.tar.gz"
    AGENT_PKG_NAME=""
done

if [[ -z "$AGENT_PKG_NAME" ]]; then
    echo "Failed to download the automation agent package from $OM_URL" >&2
    exit 1
fi

tar -zxvf "$AGENT_PKG_NAME.tar.gz" -C /opt/

# The folder inside the package does not necessarily match the file name: Ops
# Manager 9.0 still serves the "amzn2_aarch64" package, but the folder contained
# in it is named "linux_aarch64". So locate the extracted folder instead of
# assuming it is named after the downloaded file.
AGENT_PKG_DIR=""
for DIR in /opt/mongodb-mms-automation-agent-*/; do
    if [[ -d "$DIR" ]]; then
        AGENT_PKG_DIR="${DIR%/}"
        break
    fi
done
if [[ -z "$AGENT_PKG_DIR" ]]; then
    echo "Failed to extract the automation agent package $AGENT_PKG_NAME.tar.gz" >&2
    exit 1
fi
mv "$AGENT_PKG_DIR" /opt/mongodb-mms-automation
groupadd -g 900 -r mongod
useradd -u 900 -r -g mongod -s /sbin/nologin -M mongod

# Create data folder
mkdir -p /data/{db,log}
mkdir -p /var/lib/mongodb-mms-automation
mkdir -p /var/log/mongodb-mms-automation

# Clean up
yum clean all
rm -rf /var/cache/yum