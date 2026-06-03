# Pull base image.
FROM amazonlinux:2023

ARG OM_URL
ARG AGENT_VERSION
ARG IS_ARM

COPY ./setup.sh /setup.sh
COPY ./entrypoint.sh /entrypoint.sh
RUN ./setup.sh

# Define mountable directories.
VOLUME ["/data/db", "/data/log"]

# Define default command.
ENTRYPOINT [ "/entrypoint.sh" ]

# Expose ports.
EXPOSE 27017