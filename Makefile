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
	docker rmi -f $${NAMESPACE}/ops-manager:$${OM_VERSION} || true; \
	docker rmi -f $${NAMESPACE}/backup-daemon:$${OM_VERSION} || true;
rebuild: clean build
destroy: stop-om clean
	echo "Removing host data directory..."; \
	rm -rf $${HOST_PATH} config ops-manager/om/gen.key
run-om:
	source config; \
	cd ops-manager/om; \
	docker-compose up -d; \
	printf "Waiting for Ops Manager to start."; \
	until [ "$$(curl -s -L -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:$${OM_MAPPING_PORT}/)" -eq 200 ]; do \
		printf "."; \
		sleep 5; \
	done
stop-om:
	source config; \
	cd ops-manager/om; \
	docker-compose down