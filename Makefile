PROJECT_NAME = mongodb-enterprise-docker

.PHONY: config reconfig build rebuild clean destroy run-om stop-om

config:
	./configure
reconfig:
	rm -f config
	./configure
build:
	./build
clean:
	source config; \
	echo "Removing Docker images..."; \
	docker rmi -f ${NAMESPACE}/ops-manager:${OM_VERSION} || true;
rebuild: clean build
destroy: stop-om clean
	echo "Removing host data directory..."; \
	rm -rf ${HOST_PATH}
run-om:
	source config; \
	cd ops-manager/om; \
	docker-compose up -d
stop-om:
	source config; \
	cd ops-manager/om; \
	docker-compose down