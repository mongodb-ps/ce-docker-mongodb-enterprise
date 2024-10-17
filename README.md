# MongoDB & Ops Manager Docker Image

## 1 Summary
**The images are for testing purpose only. DO NOT use in production!**  
**The images are tested on Mac ARM series platforms. Other platforms are not tested.**

This is the script for building MongoDB and Ops Manager docker image.
The Ops Manager is built using:

- Ops Manager: `8.0.0`
- AppDB: MongoDB `8.0:latest`
- Base image is `ubuntu:jammy`
- TODO: Blockstore (For now, use filesystem store instead)

The MongoDB deployment image is built:

- Based on `amazonlinux:2` image (for better compatibility with older versions of MongoDB)
- Automation Agent is installed

Note the MongoDB relies on Ops Manager to start.

## 2 How does it work
### 2.1 The Ops Manager Container
Ops Manager doesn't provide pre-compiled package for ARM64 platform thus can't be run on Macbook M1/M2 series. However, Ops Manager is a Java application, which is platform independent. The only problem is the JDK included in the package is for x86_64 platform. The script uses the pre-compiled Ops Manager tarball for Ubuntu, removes `jdk` folder, then symbol link ARM64 openjdk-17 as a replacement. This is enough to resolve the jdk issue.  
For the Ops Manager to access AppDB, docker compose is used to let the 2 container run in the same network. For now the AppDB is a standalone instance. As well as Ops Manager.

### 2.2 The MongoDB Container
Each container will have automation agent installed and started. You can specify how many containers to start by setting the number in the `config.sh` or [pass it as a parameter](#mongodb). All instances are started by docker compose so that they are in the same network. For the automation agent to work correctly, you need to properly configure the API key, project ID, and Ops Manager URL. Refer to the next section for details.

## 3 Configuration

All configurations can be found in the following 3 files.

### 3.1 config.sh
Common configurations that MongoDB and Ops Manager shares.
  - `DOCKER_USERNAME`: Used as the docker image responsitory name.
  - `_HTTP_PROXY` / `_HTTPS_PROXY`: Proxy if availalbe. (Not fully tested)
### 3.2 ops-manager/config.sh
Ops Manager config.
  - `MONGODB_VERSION`: MongoDB version used for AppDB.
  - `OM_URL`: Ops Manager binary download URL.
  - `MONGO_INITDB_ROOT_USERNAME`: Initial admin account name for AppDB.
  - `MONGO_INITDB_ROOT_PASSWORD`: Initial admin password for AppDB.
  - `DB_VOLUME`: Host folder for storing AppDB data files.
  - `OM_MONGO_RELEASES`: Host folder for storing Ops Manager MongoDB releases.
  - `OM_SNAPSHOTS`: Host folder for storing backup snapshots
  - `OM_HEADDB`: Host folder for storing headDB
  - `OM_LOGS`: Host folder for storing Ops Manager logs.
### 3.3 mongo/config.sh
MongoDB deployment config.
  - `PROJECT_ID`: group/project ID in Ops Manager. This is where in Ops Manager you want to create the MongoDB cluster.
  - `API_KEY`: API KEY used by Ops Manager Automation Agent.
  - `OM_URL`: Ops Manager URL. Use `http://host.docker.internal:8080` so that your automation agent can always find your OM despite IP changes. 
  - `AA_URL`: Automation Agent download URL.
  - `INSTANCES`: Number of docker pods. Defaults to 3.
  - `BASE_DBPATH`: Host folder for `db_path`. Each instance will create a sub folder named mongo_*idx* to store DB files and logs.

## 4 Mount Points & Folders
Some of the folders are mapped to the host folders. You may need them if you want to setup backup or start a MongoDB cluster.

### 4.1 Ops Manager
- `/headDB` -> [OM_HEADDB](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/ops-manager/config.sh#L11)
- `/snapshots` -> [OM_SNAPSHOTS](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/ops-manager/config.sh#L10)
- `/mongodb-mms/mongodb-releases` -> [OM_MONGO_RELEASES](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/ops-manager/config.sh#L9) (You need to change the default releases folder the first time you start Ops Manager)

### 4.2 MongoDB
- `/data/db` -> [BASE_DBPATH](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/mongo/config.sh#L10)/db
- `/data/log` -> [BASE_DBPATH](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/mongo/config.sh#L10)/log

## 5 How to Use

- Clone this repository:

```bash
git clone https://github.com/mongodb-ps/ce-docker-mongodb-enterprise.git
```

### 5.1 Ops Manager

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

The Ops Manager port by default is mapped to `8080` on the host. Can be changed in the [docker-compose.yaml](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/ops-manager/docker-compose.yml#L24). 

If you want to setup backup, use the following settings:
- headDB: `/headDB`
- snapshots: `/snapshots`
- Oplog Store: `appdb:27017`. We reuse the AppDB as Oplog Store. No need to change the name `appdb` as it's the name of AppDB container and is resolvable.
  - Username: [MONGO_INITDB_ROOT_USERNAME](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/ops-manager/config.sh#L6)
  - Password: [MONGO_INITDB_ROOT_PASSWORD](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/ops-manager/config.sh#L7)

### 5.2 MongoDB
**MongoDB relies on Ops Manager to work. Make sure Ops Manager is running prior to start the following steps. Because the build produre will download automation agent from Ops Manager.**

- Build image:

```bash
cd ce-docker-mongodb-enterprise/mongo
./build.sh
```

- Start MongoDB
By default it will start [INSTANCES](https://github.com/mongodb-ps/ce-docker-mongodb-enterprise/blob/main/mongo/config.sh#L8C1-L9C1) (By default 3) instances. You can override the number by sending it in the command:
```bash
# This will start INSTANCES containers.
./mongo start
# Or, this will start 6 containers
./mongo start 6
```

- Stop MongoDB

```bash
./mongo stop
```

- Clean up the images
```bash
./clean.sh
```

### 5.3 Known Issues

1. Ops Manager requires at least 4GB to start (recommended 6GB). Adjust RAM limit in `Settings->Resources->Advanced` accordingly if necessary.
1. On my M1 sometimes docker service crash for no reason and can't even be restarted. This seems like a unresolved issue https://github.com/docker/for-mac/issues/5283The. The following command can help you kill docker:
```bash
kill `ps aux | grep docker | awk '{print $2}'`
```
1. After restarting docker service, the IP addresses may change which may confuse OM and cause monitoring issues. Go to More->Host Mappings, clear all mappings, wait for a few minutes and the problem should be gone.