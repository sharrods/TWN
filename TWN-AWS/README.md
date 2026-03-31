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

### What I Built
CI/CD pipeline that deploys Docker container to EC2 after build

### Pipeline Flow
```
Code Push → GitHub → Jenkins → Build JAR → Build Image → Push to ECR → Deploy to EC2
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
