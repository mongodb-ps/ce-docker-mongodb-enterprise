# Pull base image.
ARG BASE_IMG=docker-mongodb/ops-manager:latest
FROM $BASE_IMG

COPY entrypoint.sh /usr/local/bin/

# Define mountable directories.
VOLUME ["/mongodb-mms/logs", "/mongodb-mms/mongodb-releases", "/headDB", "/snapshots"]

ENTRYPOINT [ "entrypoint.sh" ]

# Expose ports.
EXPOSE 27700-27719
EXPOSE 25999
