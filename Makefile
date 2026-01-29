PROJECT_NAME = mongodb-enterprise-docker

.PHONY: config reconfig build rebuild clean destroy run-om stop-om

config:
	./configure
reconfig:
	rm -f config
	./configure
build:
	cd ops-manager; \
	./build
clean:
	source config; \
	echo "Removing Docker images..."; \
	docker rmi -f $${NAMESPACE}/ops-manager:$${OM_VERSION} || true; \
	docker rmi -f $${NAMESPACE}/backup-daemon:$${OM_VERSION} || true; \
rebuild: clean build
destroy: stop-om clean
	echo "Cleaning docker system..."; \
	docker system prune; \
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
	done; \
	echo "Ops Manager started."; \
	cd ../../; \
	RESPONSE=$$(curl --digest \
	--header "Accept: application/json" \
	--header "Content-Type: application/json" \
	--silent \
	--request POST "http://localhost:$${OM_MAPPING_PORT}/api/public/v1.0/unauth/users?pretty=true" \
	--data "{\"username\": \"$${OM_ADMIN_EMAIL}\", \"password\": \"$${OM_ADMIN_PWD}\", \"firstName\": \"$${OM_ADMIN_FIRSTNAME}\", \"lastName\": \"$${OM_ADMIN_LASTNAME}\"}"); \
	PUBLIC_KEY=$$(echo "$$RESPONSE" | jq -r '.programmaticApiKey.publicKey'); \
	PRIVATE_KEY=$$(echo "$$RESPONSE" | jq -r '.programmaticApiKey.privateKey'); \
	echo "export PUBLIC_KEY=$$PUBLIC_KEY" >> config; \
	echo "export PRIVATE_KEY=$$PRIVATE_KEY" >> config; \
	echo "Ops Manager admin user created."
stop-om:
	source config; \
	cd ops-manager/om; \
	docker-compose down