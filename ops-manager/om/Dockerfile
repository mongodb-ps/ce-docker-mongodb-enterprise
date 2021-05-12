# Pull base image.
FROM ubuntu:18.04

ARG PKG_NAME
ARG MONGO_INITDB_ROOT_USERNAME
ARG MONGO_INITDB_ROOT_PASSWORD
ADD bootstrap.sh /
ADD startup.sh /
ADD ./$PKG_NAME /
ENV DEBIAN_FRONTEND=noninteractive
RUN chmod +x ./bootstrap.sh && ./bootstrap.sh

# Define mountable directories.
VOLUME ["/opt/mongodb/mms/logs", "/opt/mongodb/mms/mongodb-releases"]

# Define default command.
CMD "/startup.sh"

# Expose ports.
EXPOSE 8080