# Pull base image.
FROM ubuntu:jammy

ARG PKG_NAME
ARG MONGOT_DATAPATH
ARG MONGOT_USER

COPY setup.sh /tmp/
COPY entrypoint.sh /usr/local/bin/

ADD ./$PKG_NAME /
RUN chmod +x /tmp/setup.sh && \
	/tmp/setup.sh && \
	rm /tmp/setup.sh

# Define mountable directories.
VOLUME ["/data/mongot"]

ENTRYPOINT [ "entrypoint.sh" ]

# Expose ports.
EXPOSE 8080 9946 27028