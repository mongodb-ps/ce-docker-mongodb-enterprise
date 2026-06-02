# MongoDB & Ops Manager Docker Image

## 1 Summary
**DISCLAIMER:**
THESE CODE SAMPLES ARE PROVIDED FOR EDUCATIONAL AND ILLUSTRATIVE PURPOSES ONLY,
TO DEMONSTRATE THE FUNCTIONALITY OF SPECIFIC MONGODB FEATURES.
THEY ARE NOT PRODUCTION-READY AND MAY LACK THE SECURITY HARDENING, ERROR HANDLING, AND TESTING REQUIRED FOR A LIVE ENVIRONMENT.
YOU ARE RESPONSIBLE FOR TESTING, VALIDATING, AND SECURING THIS CODE WITHIN YOUR OWN ENVIRONMENT BEFORE IMPLEMENTATION.
THIS MATERIAL IS PROVIDED "AS IS" WITHOUT WARRANTY OR LIABILITY.

This project aims building MongoDB and Ops Manager Docker image. You got the following features:
- Ops Manager with backup (filesystem store + oplog store). Queryable backup is yet available.
- Containers with automation agent installed (But no MongoDB deployment).
- A 1-node replica set and a `mongot` instance connected to it.

## 2 How To Use
Everything is auto-wired so you can use it with least manual settings. Follow the following steps to start Ops Manager and MongoDB.

### 2.1 Prerequisites
The following dependencies are required:
- Docker + Docker Compose
- openssl (Generating passwords, keys)
- python3 (Make API calls)
- dnsutils (`dig` command is needed to find host IP)

### 2.2 Configure
```bash
make config
```
The guide lets you choosing AppDB and Ops Manager versions, as well as some other useful options. When chooing,
- The guide only shows the latest version of each series. You can input versions not listed, but make sure they exist.
- You should choose compatible versions of Ops Manager and AppDB.
- If you use your own password, make sure it meets the complexity requirement of Ops Manager (Upper / Lower case characters, numbers and symbols.).

If you want to further customize the images, find the extra options in `config.template`.  
The final configuration will be written into `config`.

**Known issue:**
- By default the OM URL is set to `hostname -f`. However, for MacOS users, the hostname sometimes changes, which breaks connectivity. A workaround is to manually map the hostname to `127.0.0.1` in `/etc/hosts`.

### 2.3 Build & Start Ops Manager
This will build the Ops Manager image and pull AppDB image.
```bash
make build-om
```
To start Ops Manager
```bash
make run-om
```
The first time after starting, the admin user, as well as the public and private keys will be created. They will be appended to `config`.

To stop Ops Manager
```bash
make stop-om
```

### 2.4 Build & Start MongoDB
MongoDB image building requires that your Ops Manager is up and running. Because it needs to download the agent binary from the Ops Manager.
```bash
make build-mongo
```
To start 3 containers with automation agents (No deployment will be created)
```bash
make run-mongo COUNT=3
```
To stop agent containers
```bash
make stop-mongo
```
Note in the container we have 2 folers mapped to host folders:
- `/data/db` -> `$MONGO_DBPATH/mongo_1_<container_index>`
- `/data/log` -> `$MONGO_LOGPATH/mongo_1_<container_index>`

You should use them for data files and log files when creating deployments.

### 2.5 Build & Start MongoT
This target will create a 1-node replica set and a mongot instance connected to this replica set. Everything's configured.
- You can find database username / password in the generated `config`.
- The replica set is in the Ops Manager project "MongoT".
```bash
make build-mongot
```
To start the containers:
```bash
make run-mongot
```
To stop the containers:
```bash
make stop-mongot
```
The 1-node replica set has 2 folders mapped to host folders:
- `/data/db` -> `$MONGO_DBPATH/mongo_2_1`
- `/data/log` -> `$MONGO_LOGPATH/mongo_2_1`

The `mongot`'s data folder is also mapped:
- `/data/mongot` -> `$MONGOT_DATAPATH`

### 2.6 Clean Up
The `clean` target will stop container and remove images but will keep the data untouched.
```bash
# Stop Ops Manager and clean up Ops Manager images
make clean-om
# Stop MongoDB and clean up MongoDB images
make clean-mongo
# Stop MongoT and clean up MongoT image
make clean-mongot
# Stop all and clean up all images
make clean
```

### 2.6 Destroy
**IMPORTANT: Use with caution**  
This operation will
- Stop all running containers
- Clean up all unused images (Including building cache)
- Remove data folders

```bash
make destroy
```

## 3 Additional Information
### 3.1 Known Issues
1. Ops Manager requires at least 4GB to start (recommended 6GB). Adjust RAM limit in `Settings->Resources->Advanced` accordingly if necessary.
1. On my M1 sometimes docker service crash for no reason and can't even be restarted. This seems like a unresolved issue https://github.com/docker/for-mac/issues/5283The. The following command can help you kill docker:
    ```bash
    kill `ps aux | grep docker | awk '{print $2}'`
    ```
1. After restarting docker service, the IP addresses may change which may confuse OM and cause monitoring issues. Go to More->Host Mappings, clear all mappings, wait for a few minutes and the problem should be gone.
1. SMTP configuration is a dummy one. It will not work.
1. During my test I sometimes get the error after starting Ops Manager for the first time. For some reason sometimes Docker tend to proxy your request in a weird way. Not sure how this happens but usually restart Docker service will fix the problem.
   ```
   Failed to update automation config: {"detail":"IP address 185.199.111.133 is not allowed to access this resource.","error":403,"errorCode":"IP_ADDRESS_NOT_ON_ACCESS_LIST","parameters":["185.199.111.133"],"reason":"Forbidden"}
   ```

### 3.2 Other Information
- The Ops Manager image is built based on `ubuntu:jammy`.
- Th AppDB is using MongoDB official image `mongodb/mongodb-enterprise-server`.
- The MongoDB image is built based on `amazonlinux:2` for better backwards compatibility.
- Ops Manager v6, v7 and v8 are tested and should work. Other versions are not verified.