# Module 8 — CI/CD with Jenkins

## What I Built
[Fill in after completing the module]

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



- Nexus credentials
- Docker registry credentials

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



## Key Concepts
- Jenkins automates everything you did manually in modules 4-7
- Jenkinsfile lives in the repo alongside the code
- Pipeline as code = version controlled automation
- Jenkins needs same build tools as your local machine
- Credentials stored in Jenkins — never hardcoded in Jenkinsfile
- Each stage in the pipeline maps to a step you already did manually
