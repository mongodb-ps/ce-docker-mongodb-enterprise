# Pull base image.
FROM ubuntu:18.04

ARG OM_URL
ARG API_KEY
ARG ORG_ID
ADD bootstrap.sh /
ADD startup.sh /
ENV DEBIAN_FRONTEND=noninteractive
RUN chmod +x ./bootstrap.sh && ./bootstrap.sh

# Define mountable directories.
VOLUME ["/data/db", "/data/log"]

# Define default command.
CMD "/startup.sh"

# Expose ports.
EXPOSE 27017