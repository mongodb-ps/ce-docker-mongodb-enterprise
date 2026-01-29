# Pull base image.
FROM ubuntu:jammy

ARG OM_PKG_NAME
ARG ROOT_USER
ARG ROOT_PWD

COPY setup.sh /tmp/
COPY entrypoint.sh /usr/local/bin/
COPY gen.key /

ADD ./$OM_PKG_NAME /
RUN chmod +x /tmp/setup.sh && \
	/tmp/setup.sh && \
	rm /tmp/setup.sh

# Define mountable directories.
VOLUME ["/mongodb-mms/logs", "/mongodb-mms/mongodb-releases"]

ENTRYPOINT [ "entrypoint.sh" ]

# Expose ports.
EXPOSE 8080
