# MongoDB & Ops Manager Docker Image

## 1 Summary
**The images are for testing purpose only. DO NOT use in production!**  
**The images are tested on Mac ARM series platforms. Other platforms are not tested.**
**Version 8.0 requires more memory than before. Consider allocating at least 10GB for it.**

This project aims building MongoDB and Ops Manager Docker image.
- The Ops Manager image is built based on `ubuntu:jammy`.
- Th AppDB is using MongoDB official image `mongodb/mongodb-enterprise-server`.
- The MongoDB image is built based on `amazonlinux:2` for better backwards compatibility.

## 2 How To Use
Everything is auto-wired so you can use it without much settings. Follow these steps to start Ops Manager and MongoDB.

### 2.1 Configure
The guide lets you choosing AppDB and Ops Manager versions, as well as some other useful options. When chooing,
- You can input versions not listed by the guide, but make sure they exist.
- You should choose compatible versions of Ops Manager and AppDB.
```bash
make config
```
If you want to further customize the images, find the extra options in `config.template`.  
The final configuration will be written into `config`.

### 2.2 Build & Start Ops Manager
This will build the Ops Manager image and pull AppDB image.
```bash
make build
```
To start Ops Manager
```bash
make run-om
```
The first time after starting, the tool will create the admin user and a project for MongODB. Some information will be appended to `config`.

To stop Ops Manager
```bash
make stop-om
```

### 2.3 Build & Start MongoDB
MongoDB image building requires that your Ops Manager is up and running. Because it needs to download the agent execution from Ops Manager.
```bash
make build-mongo
```
To start 3 MongoDB instances
```bash
make run-mongo COUNT=3
```
To stop MongoDB instances
```bash
make stop-mongo
```
Note in the container we mapped 2 paths to host storage:
- `/data/db` -> `$MONGO_DBPATH/mongo_<container_index>`
- `/data/log` -> `MONGO_LOGPATH/mongo_<container_index>`

You should use them for data files and log files.

### 2.4 Clean Up
The `clean` target will stop container and remove images but will keep the data untouched.
```bash
# Stop Ops Manager and clean up Ops Manager images
make clean-om
# Stop MongoDB and clean up MongoDB images
make clean-mongo
# Stop all and clean up all images
make clean
```

### 2.5 Destroy
**Use with caution**
This operation will
- Stop all running containers
- Clean up all images
- Remove data folders

```bash
make destroy
```

## 3 Known Issues

1. Ops Manager requires at least 4GB to start (recommended 6GB). Adjust RAM limit in `Settings->Resources->Advanced` accordingly if necessary.
1. On my M1 sometimes docker service crash for no reason and can't even be restarted. This seems like a unresolved issue https://github.com/docker/for-mac/issues/5283The. The following command can help you kill docker:
```bash
kill `ps aux | grep docker | awk '{print $2}'`
```
1. After restarting docker service, the IP addresses may change which may confuse OM and cause monitoring issues. Go to More->Host Mappings, clear all mappings, wait for a few minutes and the problem should be gone.