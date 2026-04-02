# TWN-AWS
# Module 9 — AWS Services

## What I Built
[Fill in after completing the module]

---

## AWS Account Setup
- Created AWS account
- Region: [N. Virgina]
- Account ID: 72863543 

---

## Lesson 3 — IAM: Users, Roles and Permissions

### Key Concepts
- **User** — individual person with credentials
- **Group** — collection of users sharing same permissions
- **Role** — assigned to AWS services not people (e.g. EC2 assumes role to access S3)
- **Policy** — JSON document defining actual permissions

### What I Did
- Created IAM user: Admin 
- Created IAM group: [fill in]
- Created IAM user: [fill in]
- Created IAM role for EC2: [fill in]

### Best Practices
- Never use root account for daily tasks
- Create admin IAM user instead
- Apply least privilege — only give what is needed
- Use roles for services, users for people

---

## Lesson 4 — Regions & Availability Zones

### Key Concepts
- **Region** — geographic location (us-east-1, eu-west-1)
- **Availability Zone** — isolated data center within a region
- Each region has multiple AZs for redundancy
- Choose region closest to your users for lower latency

### My Region
- Region: [fill in]
- AZs used: [fill in]

---

## Lesson 5 — VPC: Virtual Private Cloud

### Key Concepts
- **VPC** — your own isolated private network on AWS
- **Subnet** — subdivision of VPC IP range
- **Public Subnet** — has route to Internet Gateway, reachable from internet
- **Private Subnet** — no internet gateway, not directly reachable from internet
- **Internet Gateway** — allows public subnet to reach internet
- **NAT Gateway** — allows private subnet to make outbound internet requests only
- **Route Table** — rules for where network traffic is directed

### VPC Setup
- VPC CIDR: [fill in e.g. 10.0.0.0/16]
- Public Subnet CIDR: [fill in]
- Private Subnet CIDR: [fill in]

---

## Lesson 6 — CIDR Blocks

### Key Concepts
- CIDR = Classless Inter-Domain Routing
- Format: IP address / prefix length e.g. 10.0.0.0/16
- /16 = 65,536 available IP addresses
- /24 = 256 available IP addresses
- /32 = single IP address
- Smaller the number after / = more IP addresses available

### Quick Reference
| CIDR | Hosts |
|------|-------|
| /16 | 65,536 |
| /24 | 256 |
| /28 | 16 |
| /32 | 1 |

---

## Lesson 7 — EC2: Virtual Cloud Server

### Key Concepts
- **EC2** — Elastic Compute Cloud, AWS virtual machine
- **AMI** — Amazon Machine Image, the OS template
- **Instance Type** — defines CPU, RAM, storage (t2.micro, t3.medium etc.)
- **Security Group** — virtual firewall controlling inbound/outbound traffic
- **Key Pair** — SSH key for connecting to EC2
- **Elastic IP** — static public IP address

### EC2 Instance Created
- Instance Type:t3.micro	 
- AMI: al2023-ami-2023.10.20260325.0-kernel-6.1-x86_64
- AMIID: ami-0c3389a4fa5bddaad
- Region: N.Virginia 
- VPC: 
- Subnet: [fill in]
- Security Group: [fill in]
- Key Pair: [fill in]

### Connect to EC2
ssh -i ~/.ssh/<key-name>.pem ec2-user@<ec2-public-ip>

### Security Group Rules
| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| SSH | TCP | 22 | My IP | Admin access |
| Custom | TCP | 8080 | 0.0.0.0/0 | Jenkins |
| Custom | TCP | 3000 | 0.0.0.0/0 | App port |


### Install Docker
- sudo yum install docker 
- sudo service docker start
    - [ec2-user@ip-10-2-0-206 ~]$ sudo service docker start
      Redirecting to /bin/systemctl start docker.service
- push Dockerfile to private docker repo on dockerhub
- build using node:20 
- from AWS ec2 pull the created image
    - [ec2-user@ip-10-2-0-206 ~]$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS        PORTS                                       NAMES
78646d678982   sharrods/demo-app:1.0   "docker-entrypoint.s…"   3 seconds ago   Up 1 second   0.0.0.0:3000->3080/tcp, :::3000->3080/tcp   eager_bartik
- add my <IP/32>:3000 to the inbound security group.  

---

## Lessons 8-10 — Deploy to EC2 from Jenkins Pipeline

- Create new credentials in Jenkins 
- Add credentials ssh agent in Jenkinsfile
- ssh to AWS ec2 instance 

## What I Built
Deployed a Java Maven application to AWS EC2 using a complete 
CI/CD pipeline. Jenkins automatically builds the Docker image, 
pushes to DockerHub, SSHes into EC2, and runs the container.

## Jenkins to EC2 Connection
- Added EC2 private key (.pem) to Jenkins credentials
- Jenkins uses SSH agent to connect to EC2
- Jenkins runs docker commands remotely on EC2


## Add docker compose 
- sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
- chmod +x /usr/local/bin/docker-compose
- setup script to start docker compose
- change docker compose file 
    - image:postgres:15
    - ports 5432:5432


## The Full Flow

Jenkinsfile environment block
    IMAGE_NAME = 'sharrods/demo-app:java-maven-2.0'
        ↓
shellCmd passes it to script
    bash ./server-cmds.sh sharrods/demo-app:java-maven-2.0
        ↓
server-cmds.sh receives it as $1
    export IMAGE=$1
        ↓
docker-compose uses it
    image: ${IMAGE}


### Pipeline Flow
```

peline Flow
Code Push → GitHub Webhook → Jenkins Multibranch Pipeline
    ↓
Build JAR (Maven)
    ↓
Build Docker Image
    ↓
Push to DockerHub
    ↓
SCP docker-compose.yaml + server-cmds.sh to EC2
    ↓
SSH into EC2
    ↓
Run server-cmds.sh → docker-compose up
    ↓
java-maven-app + postgres containers running on EC2Code Push → GitHub → Jenkins → Build JAR → Build Image → Push to ECR → Deploy to EC2
```


### Jenkins to EC2 Connection
- Added EC2 private key to Jenkins credentials
- Jenkins SSHs into EC2 to run docker pull and docker run

### Jenkinsfile Deploy Stage
```groovy
stage('deploy') {
    steps {
        script {
            def dockerCmd = "docker run -d -p 8080:8080 <image>:<tag>"
            sshagent(['ec2-server-key']) {
                sh "ssh -o StrictHostKeyChecking=no ubuntu@<ec2-ip> ${dockerCmd}"
            }
        }
    }
}
```

### Dockerfile
FROM amazoncorretto:17-alpine-jdk
EXPOSE 8080
COPY ./target/java-maven-app-*.jar /usr/app/
WORKDIR /usr/app
CMD java -jar java-maven-app-*.jar

### docker-compose.yaml
services:
  java-maven-app:
    image: ${IMAGE}
    ports:
      - 8080:8080
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=password

### server-cmds.sh
#!/bin/bash
export IMAGE=$1
docker-compose -f docker-compose.yaml up --detach
echo "success"

### Jenkinsfile
#!/usr/bin/env groovy

pipeline {
    agent any
    tools {
        maven 'maven-3.9'
    }
    environment {
        IMAGE_NAME = 'sharrods/demo-app:java-maven-2.0'
    }
    stages {
        stage('build app') {
            steps {
                script {
                    echo 'building application jar...'
                    sh 'mvn -f TWN-AWS/java-maven-app/pom.xml clean package'
                }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo 'building docker image...'
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-repo', 
                        passwordVariable: 'PASS', 
                        usernameVariable: 'USER')]) {
                        sh "docker build -t ${IMAGE_NAME} -f TWN-AWS/java-maven-app/Dockerfile TWN-AWS/java-maven-app"
                        sh 'echo $PASS | docker login -u $USER --password-stdin'
                        sh "docker push ${IMAGE_NAME}"
                    }
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    echo 'deploying docker image to EC2...'
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    sshagent(['ec2-server-key']) {
                        sh "scp TWN-AWS/java-maven-app/server-cmds.sh ec2-user@<ec2-ip>:/home/ec2-user"
                        sh "scp TWN-AWS/java-maven-app/docker-compose.yaml ec2-user@<ec2-ip>:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@<ec2-ip> ${shellCmd}"
                    }
                }
            }
        }
    }
}

## Jenkins to EC2 Connection
- Added EC2 private key (.pem) to Jenkins credentials as ec2-server-key
- Jenkins uses SSHagent plugin to authenticate to EC2
- server-cmds.sh runs docker-compose on EC2 remotely
- IMAGE_NAME passed as argument to server-cmds.sh via $1


### Dynamic Version Increment
- Maven reads current version from pom.xml
- Increments patch number automatically
- Sets IMAGE_NAME dynamically:
  `env.IMAGE_NAME = "sharrods/demo-app:java-maven-$version-$BUILD_NUMBER"`
- Version committed back to GitHub after build
- Next build starts from incremented version


### What Nana's Jenkinsfile Uses
- Jenkins Shared Library from GitLab for reusable functions
- `buildJar()` — builds the JAR
- `buildImage()` — builds Docker image
- `dockerLogin()` — logs into DockerHub
- `dockerPush()` — pushes image to DockerHub
- GitLab credentials for git operations


---

## Key Concepts
- docker-compose runs multiple containers together as a stack
- server-cmds.sh acts as the remote execution script on EC2
- SCP copies files from Jenkins workspace to EC2
- SSH executes commands remotely on EC2
- IMAGE variable in docker-compose passed via export in shell script
- docker-compose up --detach runs containers in background
- Removing version: from docker-compose avoids obsolete warning
- Jenkins workspace path != EC2 path, files must be SCP'd first


## Issues and Resolutions

### pom.xml not found
- Error: `Non-readable POM TWN-AWS/java-maven-app/pom.xml`
- Cause: `-f` flag needs full path to pom.xml file not just directory
- Wrong:  `mvn -f TWN-AWS/java-maven-app clean package`
- Fixed:  `mvn -f TWN-AWS/java-maven-app/pom.xml clean package`

### docker build reading docker-compose.yaml as Dockerfile
- Error: `unknown instruction: services:`
- Cause: `-f` flag was pointing to docker-compose.yaml instead of Dockerfile
- Wrong:  `docker build -t image -f TWN-AWS/java-maven-app/docker-compose.yaml`
- Fixed:  `docker build -t image -f TWN-AWS/java-maven-app/Dockerfile`
- Rule: `-f` always points to the Dockerfile specifically

### Image not found on DockerHub
- Error: `manifest for sharrods/demo-app:java-maven-1.0 not found`
- Cause: Image tag referenced in docker-compose did not exist on DockerHub
- Resolution: Updated tag to match an image that was actually pushed

### docker build requires 1 argument
- Error: `docker buildx build requires 1 argument`
- Cause: docker-compose.yaml was being passed as extra argument to docker build
- Resolution: Remove docker-compose.yaml from docker build command entirely

### Obsolete version attribute in docker-compose
- Error: `the attribute version is obsolete`
- Cause: version: '3.8' is no longer needed in modern docker-compose
- Resolution: Remove the version line from docker-compose.yaml entirely

### node:10 build failure in React app
- Error: `SyntaxError: Unexpected token` during npm build
- Cause: node:10 too old for current React dependencies
- Resolution: Updated Dockerfile base image to node:20
  (confirmed fix from TWN community forum)

### Port already allocated on EC2
- Error: `Bind for 0.0.0.0:8080 failed: port is already allocated`
- Cause: Previous container still running from last deployment
- Resolution: Added stop/rm before docker run with || true flag







---

## Lesson 11 — ECR: Elastic Container Registry

### Key Concepts
- **ECR** — AWS private Docker registry (like Nexus but managed by AWS)
- Replaces DockerHub for production AWS deployments
- Integrated with IAM — no separate credentials needed
- Image URI format: `<account-id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>`

### ECR Setup
- Repository name: [fill in]
- Repository URI: [fill in — redact account ID]
- Region: [fill in]

### Push Image to ECR
# Authenticate
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com

# Tag image
docker tag <image>:<tag> <account-id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>

# Push
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>

---

## Lessons 12-13 — AWS CLI

### Installation
# Mac
brew install awscli

# Verify
aws --version

### Configuration
aws configure
# AWS Access Key ID: [from IAM user]
# AWS Secret Access Key: [from IAM user]
# Default region: us-east-1
# Default output format: json

### Common Commands
# List EC2 instances
aws ec2 describe-instances

# List S3 buckets
aws s3 ls

# List ECR repositories
aws ecr describe-repositories

# Get ECR login token
aws ecr get-login-password --region <region>

---

## Lesson 14 — Terraform Preview
[Notes from lesson]

---

## Lesson 15 — Container Services Preview
[Notes from lesson]

---

## Issues and Resolutions
[Document as you go]
- docker build using node:10 failed
    - Resolved: checked discord and seen people used node:20 



---

## Key Concepts
- EC2 = AWS virtual machine, equivalent to DigitalOcean Droplet but integrated with entire AWS ecosystem
- IAM roles are for services/machines, IAM users are for people
- VPC = your private network on AWS, you control all traffic rules
- Security Groups = stateful firewall at instance level
- ECR = AWS managed private Docker registry
- Never commit AWS credentials — use IAM roles or aws configure
- Root account = never use for daily work, create IAM admin user instead
- Regions and AZs = geographic redundancy, choose closest to users
