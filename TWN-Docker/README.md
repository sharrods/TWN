# Module 7 — Containers with Docker

## What I Built
[Fill in after completing the module]

- postgres locally running. 
- docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS      NAMES
c3f5104f5f23   postgres:13.10   "docker-entrypoint.s…"   About a minute ago   Up About a minute   5432/tcp   zen_bhaskara

CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS      NAMES
32bfe0e620ea   redis            "docker-entrypoint.s…"   4 seconds ago    Up 4 seconds    6379/tcp   fervent_williams

ONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS      NAMES
63130e6b7340   redis:6.2        "docker-entrypoint.s…"   2 seconds ago    Up 2 seconds    6379/tcp   friendly_brown

### Check Docker network
❯ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
5421c4ab5b5e   bridge    bridge    local
622bdafae23c   host      host      local
db10e1f1aadb   none      null      local

### Create New Docker network
❯ docker network ls -f "name=mongo-network"
NETWORK ID     NAME            DRIVER    SCOPE
e462e9b3a41e   mongo-network   bridge    local


### Build Front end JS / Backend Nodejs w/ MongoDB and Mongo Express GUI to have working app
### Run Mongo 
- pull mongo image
- pull mongo express
- create mongo-network
- Add env variables
- run
❯ docker run -d \
> -p 27017:27017 \
> -e MONGO_INITDB_ROOT_USERNAME=<user> \
> -e MONGO_IINTDB_ROOT_PASSWORD=<password> \
> --name mongodb \
> --net mongo-network \
> mongo


### Run Mongo Express
docker run -d \
-p 8081:8081 \
-e ME_CONFIG_MONGODB_ADMINUSERNAME=<user> \
-e ME_CONFIG_MONGODB_ADMINPASSWORD=<pass> \
-e ME_CONFIG_BASICAUTH_USERNAME=<username> \
-e ME_CONFIG_BASICAUTH_PASSWORD=<pw> \
-e ME_CONFIG_MONGODB_SERVER=mongodb \
-e ME_CONFIG_MONGODB_URL=mongodb://mongodb:27017 \
--net mongo-network \
--name mongo-express \
mongo-express

er ps
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS          PORTS                                             NAMES
6cc49beea03f   mongo-express   "/sbin/tini -- /dock…"   44 seconds ago   Up 43 seconds   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp       mongo-express
5de78e7b3c39   mongo           "docker-entrypoint.s…"   25 minutes ago   Up 25 minutes   0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp   mongodb

### Create Database and collection
- user-account
- users

 
### MongDB Application with persistence in DB Connects to DB
{
    _id: ObjectId('69c476574e7e0bc60b0c87fc'),
    userid: 1,
    email: 'sharrod.h@example.com',
    interests: 'None',
    name: 'Sharrod Skinner'
}

{"t":{"$date":"2026-03-25T23:57:11.390+00:00"},"s":"I",  "c":"NETWORK",  "id":51800,   "ctx":"conn12","msg":"client metadata","attr":{"remote":"172.18.0.1:63826","client":"conn12","negotiatedCompressors":[],"doc":{"driver":{"name":"nodejs","version":"4.16.0"},"platform":"Node.js v25.2.1, LE","os":{"name":"darwin","architecture":"x64","version":"24.2.0","type":"Darwin"}}}}
{"t":{"$date":"2026-03-25T23:57:11.397+00:00"},"s":"I",  "c":"NETWORK",  "id":22943,   "ctx":"listener","msg":"Connection accepted","attr":{"remote":"172.18.0.1:63842","isLoadBalanced":false,"uuid":{"uuid":{"$uuid":"211ed11a-3ec9-4f72-beb9-fa3ef890fdf3"}},"connectionId":13,"connectionCount":6}}


### Create same example but using Docker-compose
- create docker-compose file
version: '3'
services:
  mongodb:
    image: mongo
    ports:
     - 27017:27017
    environment:
     - MONGO_INITDB_ROOT_USERNAME=<user>
     - MONGO_INITDB_ROOT_PASSWORD=<passwod>
  mongo-express:
    image: mongo-express
    ports:
     - 8081:8081
    restart: always
    environment:
     - ME_CONFIG_MONGODB_ADMINUSERNAME=<user>
     - ME_CONFIG_MONGODB_ADMINPASSWORD=<password>
     - ME_CONFIG_BASICAUTH_USERNAME=<user>
     - ME_CONFIG_BASICAUTH_PASSWORD=<password>
     - ME_CONFIG_MONGODB_SERVER=mongodb
     - ME_CONFIG_MONGODB_URL=mongodb://mongodb:27017

## Start docker compose you can see it created network
-running 3/3
 ✔ Network js-app_default            Created                                                                          0.2s
 ✔ Container js-app-mongodb-1        Created                                                                          1.1s
 ✔ Container js-app-mongo-express-1  Created                                                                          0.3s
Attaching to mongo-express-1, mongodb-1



### Create Dockerfile
- Dockerfile
FROM node:20-alpine

ENV MONGO_DB_USERNAME=<user> \
    MONGO_DB_PWD=<passworod>

RUN mkdir -p /home/app

COPY . /home/app

CMD ["node", "server.js"]

- Check image is created
 docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
my-app          1.0       0a150b5979d0   About a minute ago   193MB




### Change Port Binding 
❯ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                         NAMES
e814d793b288   redis     "docker-entrypoint.s…"   13 seconds ago   Up 12 seconds   0.0.0.0:6000->6379/tcp, [::]:6000->6379/tcp   wizardly_ride


### Failer Scenario trying to run two containers with same port binding
- docker run -p 6000:6379 redis:6.2
docker: Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint crazy_kirch (b1632fc0801e317e50be44fb510f9bf3b7455464b426971b8cbb9af6de4c1df0): Bind for 0.0.0.0:6000 failed: port is already allocated


### Change the name of the container and run in detach mode and define ports
 docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                                         NAMES
82bce734aabf   redis       "docker-entrypoint.s…"   3 seconds ago    Up 3 seconds    0.0.0.0:6000->6379/tcp, [::]:6000->6379/tcp   redis-latest
288966d3e99c   redis:6.2   "docker-entrypoint.s…"   43 seconds ago   Up 43 seconds   0.0.0.0:6001->6379/tcp, [::]:6001->6379/tcp   redis-older


### Images
❯ docker images
REPOSITORY      TAG       IMAGE ID       CREATED        SIZE
redis           trixie    009cc37796fb   27 hours ago   202MB
my-app          1.0       2ef11213ee46   6 months ago   241MB
debian          latest    6d8737501634   7 months ago   183MB
mongo           latest    95a98776f273   8 months ago   1.22GB
mongo-express   latest    1b23d7976f02   2 years ago    286MB
postgres        13.10     8f81e1428679   2 years ago    536MB


## Key Docker Commands Used
- docker run -e POSTGRES_PASSWORD=mysecretpassword postgres:13.10
- docker pull
- docker start
- docker stop
- docker images
- docker ps 
- docker exec -it 
- docker logs
- docker rmi
- docker run -d redis
- docker ps -a
- docker run redis:6.2
- docker run -d -p <hostport:containerport>
- docker network ls 
- docker-compose -f mongo.yaml up
- docker-compose -f mong.yaml down
- docker build -t my-app:1.0
  
### Docker Debug Commands
- ❯ docker logs e814d793b288
Starting Redis Server
1:C 25 Mar 2026 21:36:56.305 * oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 25 Mar 2026 21:36:56.306 * Redis version=8.6.2, bits=64, commit=00000000, modified=1, pid=1, just started
1:C 25 Mar 2026 21:36:56.306 * Configuration loaded


### Jump into the container shell
❯ docker exec -it 82bce734aabf /bin/bash
root@82bce734aabf:/data# ls
root@82bce734aabf:/data# pwd
/data
root@82bce734aabf:/data# cd /
root@82bce734aabf:/# ls
bin  boot  data  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@82bce734aabf:/# env
HOSTNAME=82bce734aabf
PWD=/
HOME=/root
TERM=xterm
SHLVL=1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
_=/usr/bin/env
OLDPWD=/data
root@82bce734aabf:/#




### Pull and run a container
docker pull {image}
docker run -d -p {host-port}:{container-port} --name {container-name} {image}

### Manage containers
docker stop {container}
docker start {container}
docker rm {container}
docker rmi {image}

### Debug commands
docker logs {container}
docker exec -it {container} /bin/bash
docker ps
docker ps -a
docker logs <container-id> | tail 
docker logs <container-id> -f


### Build custom image from Dockerfile
docker build -t {image-name}:{tag} .

### Tag and push to private registry (Nexus)
docker login {nexus-ip}:{port}
docker tag {image-name}:{tag} {nexus-ip}:{port}/{image-name}:{tag}
docker push {nexus-ip}:{port}/{image-name}:{tag}

### Docker Compose
docker-compose up -d
docker-compose down
docker-compose logs

## Dockerfile Structure
FROM {base-image}:{version}
ENV {KEY}={VALUE}
RUN {linux-command}
COPY {source} {destination}
CMD ["{command}", "{arg}"]

## Docker Compose Structure
version: '3'
services:
  {service-name}:
    image: {image}
    ports:
      - {host-port}:{container-port}
    environment:
      - {KEY}={VALUE}
    volumes:
      - {volume-name}:{container-path}
volumes:
  {volume-name}:

## Volume Types
| Type | Command | Use Case |
|------|---------|----------|
| Host | -v /host/path:/container/path | Dev - you control the path |
| Anonymous | -v /container/path | Temp data, not recommended |
| Named | -v name:/container/path | Production standard |

## Private Registry — Nexus Docker Repo
- Created hosted Docker repo on Nexus
- Port: [fill in]
- Login: docker login {nexus-ip}:{port}
- Push pattern: {nexus-ip}:{port}/{image-name}:{tag}

## What I Deployed
[Fill in — js-app, java-app, etc.]

### Issues and Resolutions
- issue getting the docker mongodb running with below code
❯ docker run -d \
> -p 27017:27017 \
> -e MONGO_INITDB_ROOT_USERNAME=<user> \
> -e MONGO_IINTDB_ROOT_PASSWORD=<pw> \
> --name mongodb \
> --net mongo-network \
> mongo
4620da35869799a8f20d55bb434a53cb416d4e1e18d96ea79cc60d5e17b362a7
❯ docker logs 4620da35869799a8f20d55bb434a53cb416d4e1e18d96ea79cc60d5e17b362a7

error: missing 'MONGO_INITDB_ROOT_USERNAME' or 'MONGO_INITDB_ROOT_PASSWORD'
       both must be specified for a user to be created

- RESOLVED - typo Extra "I" in ROOT_PASSWORD

## Issue with js-app getting to port 3000 
- ❯ node server.js
app listening on port 3000!
/Users/sharrods/Documents/Techworld-with-nana/TWN-Docker/js-app/app/node_modules/mongodb/lib/sdam/topology.js:292
                const timeoutError = new error_1.MongoServerSelectionError(`Server selection timed out after ${serverSelectionTimeoutMS} ms`, this.description);
                                     ^

MongoServerSelectionError: getaddrinfo ENOTFOUND mongodb
    at Timeout._onTimeout (/Users/sharrods/Documents/Techworld-with-nana/TWN-Docker/js-app/app/node_modules/mongodb/lib/sdam/topology.js:292:38)
    at listOnTimeout (node:internal/timers:605:17)
    at process.processTimers (node:internal/timers:541:7) {
  reason: TopologyDescription {
    type: 'Unknown',
    servers: Map(1) {
      'mongodb:27017' => ServerDescription {
        address: 'mongodb:27017',
        type: 'Unknown',
        hosts: [],
        passives: [],
        arbiters: [],

- RESOLVED
    - Removed Repo and started over with correct first link instead of 2nd link which was docker-compose

## Issue building my own docker file in new directory 
- ❯ docker build -t my-app:1.0 .
[+] Building 0.1s (1/1) FINISHED                                                                      docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                  0.0s
 => => transferring dockerfile: 31B                                                                                   0.0s
ERROR: failed to build: failed to solve: the Dockerfile cannot be empty

- RESOLVED 
   - My Dockerfile was empty but in vscode it was populated. Needed to manually hit save
   -  docker build -t my-app:1.0 .
[+] Building 6.5s (8/8) FINISHED   

## Key Concepts
- Image = the package/artifact (not running)
- Container = running instance of an image
- Images become containers at runtime
- Port mapping format = host:container
- Named volumes = production standard for persistence
- Docker Compose automatically creates a shared network for all services
- Private registry requires: login → tag → push
- Never use latest tag in production — always pin versions
