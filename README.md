# MongoDB & Ops Manager Docker Image

## Summary
**The images are for testing purpose only. DO NOT use in production!**  
**The images are tested on Mac ARM series platforms. Other platforms are not tested.**

This is the script for building MongoDB and Ops Manager docker image.
The Ops Manager is built using:

- Ops Manager: `7.0.2`
- AppDB: MongoDB `7.0:latest`
- TODO: Blockstore
- Base image is `ubuntu:jammy`

The MongoDB deployment image is built:

- Based on `ubuntu:jammy` image
- Automation Agent is installed

Note the MongoDB relies on Ops Manager to start.

## How does it work
### The Ops Manager Container
Ops Manager doesn't provide pre-compiled package for ARM64 platform thus can't be run on Macbook M1/M2 series. However, Ops Manager is a Java application, which is platform independent. The only problem is the JDK included in the package is for x86_64 platform. The script uses the pre-compiled Ops Manager tarball for Ubuntu, removes `jdk` folder, then symbol link ARM64 openjdk-17 as a replacement. This is enough to resolve the jdk issue.  
For the Ops Manager to access AppDB, docker compose is used to let the 2 container run in the same network. For now the AppDB is a standalone instance. As well as Ops Manager.

### The MongoDB Container
Each container will have automation agent installed and started. You can specify how many containers to start by setting the number in the `config.sh`. All instances are started by docker compose so that they are in the same network. For the automation agent to work correctly, you need to properly configure the API key, project ID, and Ops Manager URL. Refer to the next chapter for details.

## Configuration

All configurations can be found in the following 3 files.

- `config.sh`: common configurations that MongoDB and Ops Manager shares.
  - `DOCKER_USERNAME`: Used as the docker image responsitory name.
  - `_HTTP_PROXY` / `_HTTPS_PROXY`: Proxy if availalbe. (Not fully tested)
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
  - `INSTANCES`: Number of docker instances. Default to 3.

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
./mongo start
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
