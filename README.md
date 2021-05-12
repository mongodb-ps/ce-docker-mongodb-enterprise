# dockerized-mongodb

## Summary

Dockerized MongoDB and Ops Manager.
The Ops Manager is built using:

- Ops Manager: `4.2.20`
- AppDB: MongoDB `4.2:latest`
- TODO: Blockstore

The MongoDB deployment image is built:

- Based on Ubuntu `18.06` image
- Automation Agent is installed

## Usage

- Clone this repository:

```bash
git clone https://github.com/zhangyaoxing/dockerized-mongodb.git
```

- Change configuration: the configuration is in `config.sh`
- Build images:

```bash
cd dockerized-mongodb
./build.sh
```

- Start Ops Manager and its AppDB:

```bash
./run.sh
```
