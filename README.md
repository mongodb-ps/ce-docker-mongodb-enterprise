# MongoDB & Ops Manager Docker Image

## Summary
**The images are for testing purpose only. DO NOT use in production!**
This is the script for building MongoDB and Ops Manager docker image.
The Ops Manager is built using:

- Ops Manager: `6.0.10`
- AppDB: MongoDB `6.0:latest`
- TODO: Blockstore
- Base image is `ubuntu:jammy`

The MongoDB deployment image is built:

- Based on `centos:8` image
- Automation Agent is installed

Note the MongoDB relies on Ops Manager to start.

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
  - `PROJECT_ID`: group/project ID in Ops Manager. This is where in Ops Manager you want to create the MongoDB cluster.
  - `API_KEY`: API KEY used by Ops Manager Automation Agent.
  - `OM_URL`: Ops Manager URL.
  - `AA_URL`: Automation Agent download URL.

## Usage

- Clone this repository:

```bash
git clone https://github.com/mongodb-ps/ce-docker-mongodb-enterprise.git
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
Tips: 
1. Use `http://host.docker.internal:8080` as OM URL, which always maps to docker host, can make things easier in the following steps.

### MongoDB

- Build image:

```bash
cd ce-docker-mongodb-enterprise/mongo
./build.sh
```

- Start MongoDB

```bash
# This will start 3 containers
./mongo start 3
```

- Stop MongoDB

```bash
./mongo stop
```

Tips:
1. After restarting docker service, the IP addresses may change which may confuse OM and cause monitoring issues. Go to More->Host Mappings and clear all mappings can resolve the issue.

### Known Issues

1. Ops Manager requires at least 4GB to start (recommended 6GB). Adjust RAM limit in `Settings->Resources->Advanced` accordingly if necessary.
1. On my M1 sometimes docker service crash for no reason and can't even be restarted. This seems like a unresolved issue https://github.com/docker/for-mac/issues/5283The. The following command can help you kill docker:
```bash
kill `ps aux | grep docker | awk '{print $2}'`
```