PROJECT_NAME = mongodb-enterprise-docker

.PHONY: config reconfig build-om build-mongo build rebuild clean destroy run-om stop-om run-mongo stop-mongo stop
COUNT ?= 3

config:
	./configure
reconfig:
	rm -f config
	./configure
build-om:
	cd ops-manager; \
	./build; \
	cd ..
build-mongo:
	cd mongo; \
	./build; \
	cd ..
build: build-om build-mongo
clean-om:
	source config; \
	echo "Removing Ops Manager Docker images..."; \
	docker rmi -f $${NAMESPACE}/ops-manager:$${OM_VERSION} || true; \
	docker rmi -f $${NAMESPACE}/backup-daemon:$${OM_VERSION} || true;
clean-mongo:
	source config; \
	echo "Removing MongoDB Automation Agent Docker image..."; \
	docker rmi -f $${NAMESPACE}/mongodb:$${OM_VERSION} || true;
clean: clean-om clean-mongo
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
	printf "Waiting for Ops Manager to start"; \
	until [ "$$(curl -s -L -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:$${OM_MAPPING_PORT}/)" -eq 200 ]; do \
		printf "."; \
		sleep 5; \
	done; \
	echo "Ops Manager started. Initializing..."; \
	cd ../../; \
	RESPONSE=$$(curl --digest \
	--header "Accept: application/json" \
	--header "Content-Type: application/json" \
	--silent \
	--request POST "http://localhost:$${OM_MAPPING_PORT}/api/public/v1.0/unauth/users?whitelist=192.168.65.1&whitelist=127.0.0.1&whitelist=172.17.0.1" \
	--data "{\"username\": \"$${OM_ADMIN_EMAIL}\", \"password\": \"$${OM_ADMIN_PWD}\", \"firstName\": \"$${OM_ADMIN_FIRSTNAME}\", \"lastName\": \"$${OM_ADMIN_LASTNAME}\"}"); \
	PUBLIC_KEY=$$(echo "$$RESPONSE" | jq -r '.programmaticApiKey.publicKey'); \
	PRIVATE_KEY=$$(echo "$$RESPONSE" | jq -r '.programmaticApiKey.privateKey'); \
	echo "export PUBLIC_KEY=$$PUBLIC_KEY" >> config; \
	echo "export PRIVATE_KEY=$$PRIVATE_KEY" >> config; \
	echo "Ops Manager admin user created."; \
	cd ../../; \
	PROJECT_INFO=$$(python3 scripts/prepare_project.py); \
	PROJECT_ID=$$(echo "$$PROJECT_INFO" | jq -r '.project_id'); \
	AGENT_API_KEY=$$(echo "$$PROJECT_INFO" | jq -r '.agent_api_key'); \
	AGENT_VERSION=$$(echo "$$PROJECT_INFO" | jq -r '.agent_version'); \
	echo "export PROJECT_ID=$$PROJECT_ID" >> config; \
	echo "export AGENT_API_KEY=$$AGENT_API_KEY" >> config; \
	echo "export AGENT_VERSION=$$AGENT_VERSION" >> config; \
	echo "Project prepared with ID $$PROJECT_ID and Agent API Key.";
run-mongo:
	source config; \
	cd mongo; \
	docker-compose up -d --scale mongo=$(COUNT); \
	cd ../;
stop-om:
	source config; \
	cd ops-manager/om; \
	docker-compose down
stop-mongo:
	source config; \
	cd mongo; \
	docker-compose down
stop: stop-om stop-mongo