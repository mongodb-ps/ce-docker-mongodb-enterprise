PROJECT_NAME = mongodb-enterprise-docker
.SILENT:
.PHONY: config reconfig build-om build-mongo build rebuild clean-om clean-mongo clean-mongot clean destroy run-om stop-om run-mongo stop-mongo run-mongot stop-mongot stop help
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
	@echo "  build-mongot  - Build MongoT Docker image"
	@echo "  build         - Build all required Docker images (currently only Ops Manager)"
	@echo "  rebuild       - Clean and rebuild all images"
	@echo "  clean-om      - Remove Ops Manager Docker images"
	@echo "  clean-mongo   - Remove MongoDB Automation Agent Docker image"
	@echo "  clean-mongot  - Remove MongoT Docker images"
	@echo "  clean         - Remove all Docker images"
	@echo "  run-om        - Start Ops Manager and create admin user"
	@echo "  run-mongo     - Start MongoDB containers (use COUNT=N to specify number, default: 3)"
	@echo "  run-mongot    - Start MongoT instances and MongoDB replica set for MongoT (use COUNT_MONGOT=N to specify number of MongoT, default: 1; Use COUNT=M to specify number of MongoDB nodes in the replica set, default: 3)"
	@echo "  stop-om       - Stop Ops Manager"
	@echo "  stop-mongo    - Stop MongoDB instances"
	@echo "  stop          - Stop all services"
	@echo "  destroy       - Stop services, clean images, prune system, and remove data"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make config                    # Configure the environment"
	@echo "  make build                     # Build Docker images"
	@echo "  make run-om                    # Start Ops Manager"
	@echo "  make run-mongo COUNT=5         # Start 5 MongoDB containers"
	@echo "  make run-mongot COUNT=1        # Start a 1-node replica set for MongoT"
config:
	./configure
reconfig:
	rm -f config \
	./configure
build-om:
	cd ops-manager; \
	./build; \
	cd ..
build-mongo:
	source config; \
	echo "Preparing Ops Manager project for MongoDB..."; \
	python3 scripts/prepare_project.py "MongoDB Docker" "MongoDB" 1; \
	cd mongo; \
	./build; \
	cd ..
build-mongot:
	source config; \
	echo "Preparing Ops Manager projects for MongoT..."; \
	python3 scripts/prepare_project.py "MongoDB Docker" "MongoT" 2; \
	cd mongot; \
	export NUM_MONGOD=$(COUNT); \
	export PROJECT_IDX=2; \
	./build; \
	cd ..
build: build-om
clean-om: stop-om
	source config; \
	echo "Removing Ops Manager Docker images..."; \
	docker rmi -f $${NAMESPACE}/ops-manager:$${OM_VERSION} || true; \
	docker rmi -f $${NAMESPACE}/backup-daemon:$${OM_VERSION} || true; \
clean-mongo: stop-mongo
	source config; \
	echo "Removing MongoDB Automation Agent Docker image..."; \
	docker rmi -f $${NAMESPACE}/mongodb:$${OM_VERSION} || true;
clean-mongot: stop-mongot
	source config; \
	echo "Removing MongoT Docker images..."; \
	docker rmi -f $${NAMESPACE}/mongot:$${OM_VERSION} || true;
clean: clean-mongot clean-mongo clean-om
	docker network rm docker_mongodb || true;
rebuild: clean build
destroy:
	read -p "Are you sure you want to destroy all data and images? This action cannot be undone. (y/N): " CONFIRM; \
	if [ "$$CONFIRM" != "y" ] && [ "$$CONFIRM" != "Y" ]; then \
		echo "Destroy operation cancelled."; \
		exit 0; \
	fi; \
	$(MAKE) clean; \
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
		export MONGO_PORT=$$(($${MONGO_MAPPING_PORT} + $$IDX - 1)); \
		mkdir -p "$${MONGO_DBPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		mkdir -p "$${MONGO_LOGPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		docker-compose up --scale mongodb=$$IDX --no-recreate -d; \
	done; \
	cd ../;
run-mongot:
	source config; \
	cd mongot; \
	export PROJECT_IDX=2; \
	export PROJECT_ID=$$PROJECT_ID_2; \
	export AGENT_API_KEY=$$AGENT_API_KEY_2; \
	export HOST_COUNT=$(COUNT); \
	for IDX in $$(seq 1 $(COUNT)); do \
		export IDX; \
		mkdir -p "$${MONGO_DBPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		mkdir -p "$${MONGO_LOGPATH}/mongo_$${PROJECT_IDX}_$${IDX}"; \
		docker-compose up --scale mongot_mongo=$$IDX --no-recreate -d; \
	done; \
	cd ../; \
	echo "Creating MongoDB cluster for search..."; \
	export LATEST_VERSION=$$(python3 scripts/latest_version.py); \
	export RS_NAME="rs_mongot"; \
	export PROJECT_IDX=2; \
	python3 scripts/create_cluster.py;
	echo "MongoDB cluster for MongoT created.";
stop-om:
	source config; \
	cd ops-manager/om; \
	docker-compose down
stop-mongo:
	source config; \
	cd mongo; \
	export PROJECT_IDX=1; \
	export PROJECT_ID=$$PROJECT_ID_1; \
	export AGENT_API_KEY=$$AGENT_API_KEY_1; \
	export IDX=1; \
	export MONGO_PORT=$${MONGO_MAPPING_PORT}; \
	docker-compose down
stop-mongot:
	source config; \
	cd mongot; \
	export PROJECT_IDX=2; \
	export PROJECT_ID=$$PROJECT_ID_2; \
	export AGENT_API_KEY=$$AGENT_API_KEY_2; \
	export IDX=1; \
	export RS_NAME="rs_mongot"; \
	docker-compose down
stop: stop-mongot stop-mongo stop-om