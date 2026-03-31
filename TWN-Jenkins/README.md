# Module 8 — CI/CD with Jenkins

## What I Built
Deployed Jenkins in Docker on a DigitalOcean Droplet. 
Built a CI/CD pipeline that pulls from GitHub, builds 
a JAR with Maven, and packages it into a Docker image


## Droplet Specs
- Ubuntu 24.04
- 4GB/2 CPU's

## Jenkins Setup
- install docker 
- docker run -p 8080:8080 -p 50000:50000 -d #bind 2nd port for helpers 
- add volumes -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
- initialize jenkins 
- Add maven plugin and configure 
- Install npm and node in jenkins container
- Install as root by using -u 0 



### Install Jenkins
apt update
docker run -p 8080:8080 -p 50000:50000 -d \
> -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts


### Start and verify Jenkins

root@ubuntu-s-2vcpu-4gb-nyc1-01:~# docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS                                                                                          NAMES
0ca1d6e41d05   jenkins/jenkins:lts   "/usr/bin/tini -- /u…"   22 minutes ago   Up 22 minutes   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp, 0.0.0.0:50000->50000/tcp, [::]:50000->50000/tcp   pedantic_burnell

### Get initial admin password
cat /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword

### Verify Jenkins is running
- root@ubuntu-s-2vcpu-4gb-nyc1-01:~# netstat -tlpn | grep 8080
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      3381/docker-proxy
tcp6       0      0 :::8080                 :::*                    LISTEN      3386/docker-proxy


## Accessing Jenkins
- URL: http://<droplet-ip>:8080
- Default user: admin
- Initial password: /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword 



## Install Build Tools on Jenkins Server
- install curl 
- curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
- chmod +x nodesource_setup.sh
- Stage view plugin                # visual for pipeline 
- 
 

### Install Maven
apt install -y maven
mvn -version

### Install Node/npm in container as root	
- docker exec -u 0 -it 0ca1d6e41d05 /bin/bash
- apt install nodejs -y 
  roott@0ca1d6e41d05:/# node -v
  v20.20.0
  root@0ca1d6e41d05:/# npm -v
  10.8.2




### Install Docker on Jenkins server
apt install -y docker.io



## Jenkins Plugins Installed
- [List plugins you install during setup]
- Git
- Maven Integration
- NodeJS
- Docker Pipeline

## Jenkins Configuration

### Global Tool Configuration
- JDK: [version configured]
- Maven: [version configured]
- NodeJS: [version configured]

### Credentials Added
- GitHub credentials 
https://github.com/sharrods/TWN.git 
- Setup PAT on github 
[my-job] $ /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven-3.9/bin/mvn --version
Apache Maven 3.9.2 (c9616018c7a021c1c39be70fb2843d6f5f9b8a1c)
Maven home: /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven-3.9
Java version: 21.0.9, vendor: Eclipse Adoptium, runtime: /opt/java/openjdk
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "6.8.0-71-generic", arch: "amd64", family: "unix"
Finished: SUCCESS

### Create Branch jenkins-jobs and add script to run in job 
First time build. Skipping changelog.
[my-job] $ /bin/sh -xe /tmp/jenkins16661257554679566832.sh
+ chmod +x freestyle-build.sh
+ ./freestyle-build.sh
10.8.2
[my-job] $ /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven-3.9/bin/mvn --version


### Jar file created from mvn test and mvn package. 
jenkins@0ca1d6e41d05:/$ ls /var/jenkins_home/workspace/java-maven-build
jenkins@0ca1d6e41d05:/$ ls /var/jenkins_home/workspace/java-maven-build/target/
java-maven-app-1.1.0-SNAPSHOT.jar  java-maven-app-1.1.0-SNAPSHOT.jar.original  maven-archiver


### Create new contain but keep the volume that was created before.
- docker run -p 8080:8080 -p 50000:50000 -d \
-v jenkins_home:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts

### Run docker inside the container and install 
root@e730c15e2a81:/# curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22405  100 22405    0     0   493k      0 --:--:-- --:--:-- --:--:--  497k
# Executing docker install script, commit: f381ee68b32e515bb4dc034b339266aff1fbc460
+ sh -c apt-get -qq update >/dev/null
+ sh -c DEBIAN_FRONTEND=noninteractive apt-get -y -qq install ca-certificates curl >/dev/null
+ sh -c install -m 0755 -d /etc/apt/keyrings
+ sh -c curl -fsSL "https://download.docker.com/linux/debian/gpg" -o /etc/apt/keyrings/docker.asc
+ sh -c chmod a+r /etc/apt/keyrings/docker.asc
+ sh -c echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" > /etc/apt/sources.list.d/docker.list
+ sh -c apt-get -qq update >/dev/null
+ sh -c DEBIAN_FRONTEND=noninteractive apt-get -y -qq install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin docker-model-plugin >/dev/null
Using systemd to manage Docker service
+ sh -c systemctl enable --now docker.service
WARNING: unable to enable the docker service

+ sh -c docker version
Client: Docker Engine - Community
 Version:           29.3.1
 API version:       1.50 (downgraded from 1.54)
 Go version:        go1.25.8
 Git commit:        c2be9cc
 Built:             Wed Mar 25 16:13:49 2026
 OS/Arch:           linux/amd64
 Context:           default

Server:
 Engine:
  Version:          28.2.2
  API version:      1.50 (minimum version 1.24)
  Go version:       go1.23.1
  Git commit:       28.2.2-0ubuntu1~24.04.1
  Built:            Wed Sep 10 14:16:39 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.7.28
  GitCommit:
 runc:
  Version:          1.3.3-0ubuntu1~24.04.3
  GitCommit:
 docker-init:
  Version:          0.19.0
  GitCommit:

### Change permissions on docker socket file so we can run commands inside container as jenkins user
- root@e730c15e2a81:/# ls -l /var/run/docker.sock
srw-rw---- 1 root 112 0 Mar 27 16:16 /var/run/docker.sock
- root@e730c15e2a81:/# chmod 666 /var/run/docker.sock
- root@e730c15e2a81:/# ls -l /var/run/docker.sock
srw-rw-rw- 1 root 112 0 Mar 27 16:16 /var/run/docker.sock

jenkins@e730c15e2a81:/$ docker pull redis
Using default tag: latest
latest: Pulling from library/redis
ec781dee3f47: Pull complete
5f7274725e4f: Pull complete
f4f2f7018ed9: Pull complete
3f63903b0cb8: Pull complete
c9ff57cee690: Pull complete
4f4fb700ef54: Pull complete
3e6b2202a764: Pull complete
Digest: sha256:009cc37796fbdbe1b631b4cc0582bed167e5e403ed8bcd06f77eb6cb5aeb6f93
Status: Downloaded newer image for redis:latest
docker.io/library/redis:latest

### Push to private docker repository 
jma-1.1: digest: sha256:947267eb942d681d234c24d46a6d80e5628753a6a8b8eef1c0f7fd21ade0059d size: 1159
Finished: SUCCESS


### Push to nexus private docker repo 
- restart docker 
    - systemctl restart docker
    - docker ps 
    - start docker back up 

root@ubuntu-s-2vcpu-4gb-nyc1-01:~# docker start e730c15e2a81
e730c15e2a81
root@ubuntu-s-2vcpu-4gb-nyc1-01:~# docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED       STATUS         PORTS                                                                                          NAMES
e730c15e2a81   jenkins/jenkins:lts   "/usr/bin/tini -- /u…"   2 hours ago   Up 2 seconds   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp, 0.0.0.0:50000->50000/tcp, [::]:50000->50000/tcp   relaxed_aryabhata




## Freestyle Job vs Pipeline Job
| Type | Use Case |
|------|---------|
| Freestyle | Simple builds, single steps |
| Pipeline | Complex multi-stage builds, preferred |

## Jenkinsfile Structure
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Push to Nexus') {
            steps {
                sh 'mvn deploy'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-app:1.0 .'
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'docker push <nexus-ip>:8083/my-app:1.0'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker run -d my-app:1.0'
            }
        }
    }
}

## Pipeline Flow
Code Push → GitHub → Jenkins Trigger → Build → Test → Push Artifact → Build Image → Push Image → Deploy

## What Jenkins Connects To
- GitHub: pulls source code
- Nexus: pushes JAR artifacts and Docker images
- DigitalOcean server: deploys the application


### Jenkins files, pipeplines and replay features. 
- Parameters with expression 
- paramters with user input 
- basic build steps
- parameters with groovy script
- jenkensfile wtih envrionment
- replay in jenkins files 





## Issues and Resolutions
### Github connection failures. 
- github no longer lets you use username/password. 
- setup PAT and still failed 
Avoid second fetch
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse origin/master^{commit} # timeout=10
ERROR: Couldn't find any revision to build. Verify the repository and branch configuration for this job.
    - Resolved
	Changed master —> main 

### Jenkins could not find pom.xml
- Error: `No POM in this directory (/var/jenkins_home/workspace/java-maven-build)`
- Cause: Jenkins looks for pom.xml in repo root by default
- Resolution: Set POM path in job config
  - Build → Invoke top-level Maven targets → Advanced → POM
  - Value: `TWN-BuildTools/java-maven-app/pom.xml`

### Local and remote branches diverged
- Error: `Need to specify how to reconcile divergent branches`
- Resolution: `git pull --rebase origin jenkins-jobs`
- Set as default: `git config --global pull.rebase true`


### Docker build could not find Dockerfile
- Error: `open Dockerfile: no such file or directory`
- Cause: Jenkins runs commands from repo root, not project subfolder
- Resolution: Added `cd TWN-Jenkins/java-maven-app` before docker build

### Docker could not find JAR file
- Error: `lstat /target: no such file or directory`  
- Cause: Maven POM path was wrong, JAR built in wrong directory
- Resolution: Set POM path to `TWN-Jenkins/java-maven-app/pom.xml`


### Docker push failed - tag does not exist
- Error: `tag does not exist: sharrods/demo-app:jma-1.1`
- Cause: Build tag and push tag were mismatched
- Resolution: Ensure docker build -t and docker push use identical tags

### Jenkins could not push to Nexus Docker registry
- Error: `context deadline exceeded` connecting to Nexus
- Cause: Jenkins server IP not in Nexus firewall inbound rules
- Resolution: Added Jenkins server IP to Nexus droplet firewall
- Lesson: All server-to-server communication needs explicit firewall rules



cript.groovy not found by Jenkins
- Error: `NoSuchFileException: /var/jenkins_home/workspace/my-pipeline/script.groovy`
- Cause: Jenkins looks for script.groovy in workspace root by default
- Resolution: Update load path in Jenkinsfile to match actual file location
  - Wrong:  `gv = load "script.groovy"`
  - Fixed:  `gv = load "TWN-Jenkins/java-maven-app/script.groovy"`

### MissingPropertyException - function not found
- Error: `MissingPropertyException: No such property: buildApp`
- Cause: Two issues combined:
  1. Calling function without script object reference
  2. Missing () on function calls — referencing function instead of calling it
- Resolution:
  - Always call functions through the loaded script object: `gv.buildApp()`
  - Always include () to actually execute the function
  - Wrong:  `buildApp`     ← no object reference, no call
  - Wrong:  `gv.buildApp`  ← has object reference but never executes
  - Fixed:  `gv.buildApp()` ← correct object reference with execution

## Key Groovy Concepts
- `return this` at bottom of script.groovy makes functions accessible
- `def gv = load "path/script.groovy"` loads the script as an object
- All functions must be called through that object: `gv.functionName()`
- Single quotes = literal string, no variable substitution
- Double quotes = variables get substituted: `"deploying ${VERSION}"`
- `()` executes a function — without it you are just referencing it

### mvn package running from wrong directory
- Error: No POM in workspace root
- Cause: Each sh command runs in a fresh shell
  so `sh 'cd path'` has no effect on next sh command
- Resolution: Use mvn -f flag to specify pom.xml location
  - Wrong: `sh 'cd TWN-Jenkins/java-maven-app && mvn package'`
  - Better: `sh 'mvn -f TWN-Jenkins/java-maven-app package'`
- The -f flag tells Maven exactly where the pom.xml lives
  without needing to change directories

### Docker build issues in Jenkinsfile pipeline

#### Misspelled usernamePassword in withCredentials
- Error: `No such DSL method 'usernamePasssword'`
- Cause: Typo — three s's in password
- Resolution: `usernamePassword` — two s's only

#### docker build requires 1 argument
- Error: `docker buildx build requires 1 argument`
- Cause: Missing build context (the `.` at the end)
- Resolution: Always end docker build with context path
  - Fixed: `docker build -t image:tag .`

#### Dockerfile not found after adding .
- Error: `open Dockerfile: no such file or directory`
- Cause: Running docker build from wrong directory
- Resolution: Use -f to specify Dockerfile path explicitly

#### -f flag pointing to directory instead of file
- Error: `read java-maven-app: is a directory`
- Cause: -f flag must point to the Dockerfile file not the folder
- Wrong:  `docker build -t app:1.0 -f TWN-Jenkins/java-maven-app .`
- Fixed:  `docker build -t app:1.0 -f TWN-Jenkins/java-maven-app/Dockerfile TWN-Jenkins/java-maven-app`
- Rule: -f = path to Dockerfile, last argument = build context directory


### Tag mismatch on docker push to docker hub
- Error: `tag does not exist: 143.244.171.154:8083/java-maven-app:2.0`
- Cause: Built image with sharrods/demo-app:jma-2.0 tag
  but tried to push with Nexus tag that was never created
- Resolution: Push the same tag that was built
  - Build:  `docker build -t sharrods/demo-app:jma-2.0`
  - Push:   `docker push sharrods/demo-app:jma-2.0`
- Rule: You can only push a tag that exists locally





## Key Concepts
- Jenkins automates everything you did manually in modules 4-7
- Jenkinsfile lives in the repo alongside the code
- Pipeline as code = version controlled automation
- Jenkins needs same build tools as your local machine
- Credentials stored in Jenkins — never hardcoded in Jenkinsfile
- Each stage in the pipeline maps to a step you already did manually
