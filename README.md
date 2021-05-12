# dockerized-mongodb

## Summary

Dockerized MongoDB and Ops Manager.
The Ops Manager is built using:

- Ops Manager: `4.4.12`
- AppDB: MongoDB `4.4:latest`
- TODO: Blockstore

The MongoDB deployment image is built:

- Based on Ubuntu `18.06` image
- Automation Agent is installed

Note the MongoDB here relies on Ops Manager to start. For now only 1 instance of MongoDB can be started.

## Configuration

All configurations can be found in the following 3 files:

- `config.sh`: common parameters that MongoDB and Ops Manager shares.
  - `DOCKER_USERNAME`: Used as the docker image responsitory name.
  - `_HTTP_PROXY` / `_HTTPS_PROXY`: Proxy if availalbe.
- `ops-manager/config.sh`: Ops Manager config.
  - `MONGODB_VERSION`: MongoDB version used for AppDB.
  - `OM_URL`: Ops Manager download URL.
  - `MONGO_INITDB_ROOT_USERNAME`: Initial admin account name for AppDB.
  - `MONGO_INITDB_ROOT_PASSWORD`: Initial admin password. DO CHANGE THE PASSWORD!
  - `DB_VOLUME`: Host folder for storing AppDB data files.
  - `OM_MONGO_RELEASES`: Host folder for storing Ops Manager MongoDB releases.
  - `OM_LOGS`: Host folder for storing Ops Manager logs.
- `mongo/config.sh`: parameters that's used by MongoDB deployment.
  - `GROUP_ID`: group/project ID in Ops Manager. This is where in Ops Manager you want to create the MongoDB cluster.
  - `API_KEY`: API KEY used by Ops Manager Automation Agent.
  - `OM_URL`: Ops Manager URL.
  - `AA_URL`: Automation Agent download URL.
  - `DB_PATH`: folder on host where you want to store data files.
  - `LOG_PATH`: folder on host where you want to store log files.
  - `DB_HOSTNAME`: hostname for container. The host name must be resolvable and resolve to the docker host.
  - `DB_PORT`: the port used by MongoDB node.

## Usage

- Clone this repository:

```bash
git clone https://github.com/zhangyaoxing/dockerized-mongodb-ent.git
```

### Ops Manager

- Build images:

```bash
cd dockerized-mongodb-ent/ops-manager
./build.sh
```

- Start Ops Manager and its AppDB:

```bash
./mms start
```

- Stop Ops Manager and its AppDB:

```bash
./mms stop
```

- Clean up

```bash
./clean.sh
```

### MongoDB

- Build image:

```bash
cd dockerized-mongodb-ent/mongo
./build.sh
```

- Start MongoDB

```bash
docker-compose up -d
```

- Stop MongoDB

```bash
docker-compose down
```

### Known Issues

1. On MacOS by default docker will use only 2GB RAM. However, Ops Manager requires at least 4GB to start (recommended 6GB). Please adjust RAM limit in `Settings->Resources->Advanced`
