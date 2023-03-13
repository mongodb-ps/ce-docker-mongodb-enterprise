# Pull base image.
FROM ubuntu:jammy

ARG PKG_NAME
ARG MONGO_INITDB_ROOT_USERNAME
ARG MONGO_INITDB_ROOT_PASSWORD
ADD bootstrap.sh /
ADD startup.sh /
ADD ./$PKG_NAME /
RUN set -eux; \
	groupadd --gid 999 --system mongodb-mms; \
	useradd --uid 999 --system --gid mongodb-mms --home-dir /mongodb-mms mongodb-mms;

# RUN tar -zxvf $PKG_NAME -C /opt/mongodb/
RUN chmod +x ./bootstrap.sh && ./bootstrap.sh

# Define mountable directories.
VOLUME ["/mongodb-mms/logs", "/mongodb-mms/mongodb-releases", "/headDB", "/snapshots"]

# Define default command.
CMD "/startup.sh"

# Expose ports.
EXPOSE 8080
