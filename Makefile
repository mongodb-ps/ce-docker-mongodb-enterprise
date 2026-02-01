PROJECT_NAME = mongodb-enterprise-docker
.SILENT:
.PHONY: config reconfig build-om build-mongo build rebuild clean destroy run-om stop-om run-mongo stop-mongo stop help
COUNT ?= 3

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@echo "  config        - Run configuration script to create config file"
	@echo "  reconfig      - Remove existing config and run configuration again"
	@echo "  build-om      - Build Ops Manager Docker image"
	@echo "  build-mongo   - Build MongoDB Automation Agent Docker image"
	@echo "  build         - Build all required Docker images (currently only Ops Manager)"
	@echo "  rebuild       - Clean and rebuild all images"
	@echo "  clean-om      - Remove Ops Manager Docker images"
	@echo "  clean-mongo   - Remove MongoDB Automation Agent Docker image"
	@echo "  clean         - Remove all Docker images"
	@echo "  run-om        - Start Ops Manager and create admin user"
	@echo "  run-mongo     - Start MongoDB instances (use COUNT=N to specify number, default: 3)"
	@echo "  stop-om       - Stop Ops Manager"
	@echo "  stop-mongo    - Stop MongoDB instances"
	@echo "  stop          - Stop all services"
	@echo "  destroy       - Stop services, clean images, prune system, and remove data"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make config              # Configure the environment"
	@echo "  make build               # Build Docker images"
	@echo "  make run-om              # Start Ops Manager"
	@echo "  make run-mongo COUNT=5   # Start 5 MongoDB instances"

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
build: build-om
clean-om: stop-om
	source config; \
	echo "Removing Ops Manager Docker images..."; \
	docker rmi -f $${NAMESPACE}/ops-manager:$${OM_VERSION} || true; \
	docker rmi -f $${NAMESPACE}/backup-daemon:$${OM_VERSION} || true;
clean-mongo: stop-mongo
	source config; \
	echo "Removing MongoDB Automation Agent Docker image..."; \
	docker rmi -f $${NAMESPACE}/mongodb:$${OM_VERSION} || true;
clean: clean-om clean-mongo
rebuild: clean build
destroy: clean
	source config; \
	echo "Cleaning docker system..."; \
	docker system prune; \
	echo "Removing host data directory..."; \
	rm -rf $${HOST_PATH} config ops-manager/om/gen.key
run-om:
	source config; \
	cd ops-manager/om; \
	echo "Creating shared network for Ops Manager and MongoDB"; \
	docker network inspect docker_mongodb >/dev/null 2>&1 || docker network create docker_mongodb; \
	echo "Starting Ops Manager..."; \
	docker-compose up --no-recreate -d --wait; \
	echo "Ops Manager started. Initializing..."; \
	cd ../../; \
	if [[ "$$PUBLIC_KEY" == "" && "$$PRIVATE_KEY" == "" ]]; then \
		RESPONSE=$$(curl --digest \
		--header "Accept: application/json" \
		--header "Content-Type: application/json" \
		--silent \
		--request POST "http://localhost:$${OM_MAPPING_PORT}/api/public/v1.0/unauth/users?whitelist=192.168.65.1&whitelist=127.0.0.1&whitelist=172.17.0.1" \
		--data "{\"username\": \"$${OM_ADMIN_EMAIL}\", \"password\": \"$${OM_ADMIN_PWD}\", \"firstName\": \"$${OM_ADMIN_FIRSTNAME}\", \"lastName\": \"$${OM_ADMIN_LASTNAME}\"}"); \
		export PUBLIC_KEY=$$(echo "$$RESPONSE" | jq -r '.programmaticApiKey.publicKey'); \
		export PRIVATE_KEY=$$(echo "$$RESPONSE" | jq -r '.programmaticApiKey.privateKey'); \
		echo "export PUBLIC_KEY=$$PUBLIC_KEY" >> config; \
		echo "export PRIVATE_KEY=$$PRIVATE_KEY" >> config; \
	echo "Ops Manager admin user created."; \
	else \
		echo "Ops Manager admin user already exists. Skipping creation."; \
	fi; \
	if [[ "$$PROJECT_ID" != "" && "$$AGENT_API_KEY" != "" && "$$AGENT_VERSION" != "" ]]; then \
		echo "Project already prepared. Skipping project preparation."; \
	else \
		PROJECT_INFO=$$(python3 scripts/prepare_project.py); \
		PROJECT_ID=$$(echo "$$PROJECT_INFO" | jq -r '.project_id'); \
		AGENT_API_KEY=$$(echo "$$PROJECT_INFO" | jq -r '.agent_api_key'); \
		AGENT_VERSION=$$(echo "$$PROJECT_INFO" | jq -r '.agent_version'); \
		echo "export PROJECT_ID=$$PROJECT_ID" >> config; \
		echo "export AGENT_API_KEY=$$AGENT_API_KEY" >> config; \
		echo "export AGENT_VERSION=$$AGENT_VERSION" >> config; \
		echo "Project prepared with ID $$PROJECT_ID and Agent API Key."; \
	fi; \
	echo "Enabling backup daemon..."; \
	python3 scripts/enable_daemon.py; \
	cd ../;
run-mongo:
	source config; \
	cd mongo; \
	for IDX in $$(seq 1 $(COUNT)); do \
		export IDX; \
		mkdir -p "$${MONGO_DBPATH}/mongo_$${IDX}"; \
		mkdir -p "$${MONGO_LOGPATH}/mongo_$${IDX}"; \
		docker-compose up --scale mongo=$$IDX --no-recreate -d; \
	done; \
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