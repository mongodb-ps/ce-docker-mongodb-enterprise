# MongoDB & Ops Manager Docker Image

## Summary
**The images are for testing purpose only**
This is the script to build MongoDB and Ops Manager docker image.
The Ops Manager is built using:

- Ops Manager: `6.0.10`
- AppDB: MongoDB `6.0:latest`
- TODO: Blockstore

The MongoDB deployment image is built:

- Based on `ubuntu:jammy` image
- Automation Agent is installed

Note the MongoDB here relies on Ops Manager to start. For now only 1 instance of MongoDB can be started.

## How does it work
Ops Manager doesn't provide pre-compiled version for ARM64 platform thus can't be run on Macbook M1/M2 series. However, Ops Manager is a Java application, which is capable to run on ARM64 platform. The only problem is the JDK included in the package is for x86_64 platform. The script uses the pre-compiled Ops Manager package for Ubuntu, removes `jdk` folder, then link ARM64 openjdk-11 as a replacement. This is enough to resolve the jdk issue.

## Configuration

All configurations can be found in the following 3 files.

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
  - `OM_SNAPSHOTS`: Host folder for storing backup snapshots
  - `OM_HEADDB`: Host folder for storing headDB
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
git clone https://github.com/zhangyaoxing/ce-docker-mongodb-enterprise.git
```

### Ops Manager

- Build images:

```bash
cd ce-docker-mongodb-enterprise/ops-manager
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

- Clean up the images

```bash
./clean.sh
```

### MongoDB

- Build image:

```bash
cd ce-docker-mongodb-enterprise/mongo
./build.sh
```

- Start MongoDB

```bash
./mongo start
```

- Stop MongoDB

```bash
./mongo stop
```

### Known Issues

1. Ops Manager requires at least 4GB to start (recommended 6GB). Adjust RAM limit in `Settings->Resources->Advanced` accordingly if necessary.
