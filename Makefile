PROJECT_NAME = mongodb-enterprise-docker
.SILENT:
.PHONY: config reconfig build-om build-mongo build rebuild clean destroy run-om stop-om run-mongo stop-mongo run-mongot stop-mongot stop help
COUNT ?= 3
COUNT_MONGOT ?= 1

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
	docker rmi -f $${NAMESPACE}/backup-daemon:$${OM_VERSION} || true; \
	docker network rm docker_mongodb || true;
clean-mongo: stop-mongo
	source config; \
	echo "Removing MongoDB Automation Agent Docker image..."; \
	docker rmi -f $${NAMESPACE}/mongodb:$${OM_VERSION} || true;
clean: clean-mongo clean-om
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
	echo "Ops Manager started. Creating first user..."; \
	cd ../../; \
	python3 scripts/create_first_user.py; \
	source config; \
	echo "Preparing Ops Manager projects..."; \
	python3 scripts/prepare_project.py "MongoDB Docker" "MongoDB" 1; \
	python3 scripts/prepare_project.py "MongoDB Docker" "MongoT" 2; \
	echo "Enabling backup daemon..."; \
	python3 scripts/enable_daemon.py; \
	echo "Creating oplog store and file system store..."; \
	python3 scripts/create_store.py; \
	cd ../;
run-mongo:
	source config; \
	cd mongo; \
	export PROJECT_IDX=1; \
	export PROJECT_ID=$$PROJECT_ID_1; \
	export AGENT_API_KEY=$$AGENT_API_KEY_1; \
	for IDX in $$(seq 1 $(COUNT)); do \
		export IDX; \
		mkdir -p "$${MONGO_DBPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		mkdir -p "$${MONGO_LOGPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		docker-compose up --scale mongo=$$IDX --no-recreate -d; \
	done; \
	cd ../;
run-mongot:
	source config; \
	cd mongot; \
	export PROJECT_IDX=2; \
	export PROJECT_ID=$$PROJECT_ID_2; \
	export AGENT_API_KEY=$$AGENT_API_KEY_2; \
	for IDX in $$(seq 1 $(COUNT_MONGOT)); do \
		export IDX; \
		mkdir -p "$${MONGO_DBPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		mkdir -p "$${MONGO_LOGPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		docker-compose up --scale mongot_mongo=$$IDX --no-recreate -d; \
	done; \
	cd ../;
stop-om:
	source config; \
	cd ops-manager/om; \
	docker-compose down
stop-mongo:
	source config; \
	cd mongo; \
	export IDX=1; \
	docker-compose down
stop-mongot:
	source config; \
	cd mongot; \
	export IDX=2; \
	docker-compose down
stop: stop-om stop-mongo stop-mongot