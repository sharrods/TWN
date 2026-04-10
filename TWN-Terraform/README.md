# TWN-Terraform
# Module 12 — Terraform
### What I Built
- Provisioned full EKS cluster on AWS using Terraform community modules
- Created VPC with public and private subnets across multiple availability zones
- Deployed managed node group with 3 t3.small worker nodes
- Used terraform-aws-modules/vpc/aws and terraform-aws-modules/eks/aws community modules
- Connected VPC module outputs directly to EKS module inputs
- All 62 resources created with single terraform apply
- Cluster took ~15 minutes to provision

---

## Lesson 3 — Providers in Terraform

### What is a Provider
- plugin that lets Terraform talk to a specific platform
- AWS, GCP, Azure, DigitalOcean, Linode all have providers
- provider downloads when you run `terraform init`

### Provider Block
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Commands
```bash
terraform init      # downloads provider plugins
terraform plan      # shows what will be created/changed/destroyed
terraform apply     # creates the infrastructure
terraform destroy   # destroys everything
```

---

## Lesson 4 — Resources and Data Sources

### Resources
- what Terraform creates and manages
- EC2, VPC, S3, security groups etc.
```hcl
resource "aws_instance" "my-server" {
  ami           = "ami-0c3389a4fa5bddaad"
  instance_type = "t2.micro"

  tags = {
    Name = "my-server"
  }
}
```

### Data Sources
- read existing infrastructure you didn't create with Terraform
- query AWS for existing AMIs, VPCs, subnets etc.
```hcl
data "aws_ami" "latest-amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

### Difference
- resource = Terraform creates and owns it
- data source = Terraform reads it, someone else owns it

---

## Lesson 5 — Change and Destroy Terraform Resources

### Change
- edit your .tf file
- run `terraform plan` to preview changes
- run `terraform apply` to apply changes
- Terraform figures out what to add/change/remove

### Destroy
```bash
# Destroy everything in the current workspace
terraform destroy

# Destroy specific resource
terraform destroy -target aws_instance.my-server
```

---

## Lesson 6 — Terraform Commands
```bash
terraform init          # initialize working directory, download providers
terraform plan          # preview changes before applying
terraform apply         # apply changes
terraform apply -auto-approve  # apply without confirmation prompt
terraform destroy       # destroy all resources
terraform show          # show current state
terraform state list    # list all resources in state
terraform output        # show output values
terraform fmt           # format .tf files
terraform validate      # validate configuration syntax
```

---

## Lesson 7 — Terraform State

### What State Is
- Terraform keeps a record of everything it created in a state file
- `terraform.tfstate` — JSON file mapping your config to real resources
- Terraform compares state to your config to know what to change

### Why State Matters
- without state Terraform doesn't know what already exists
- if you delete state file Terraform loses track of resources
- resources still exist in AWS but Terraform doesn't know about them

### State Commands
```bash
terraform state list              # list all tracked resources
terraform state show <resource>   # show details of one resource
terraform state rm <resource>     # remove resource from state (doesn't delete it)
```

### Remote State
- store state file in S3 instead of locally
- allows team collaboration
- prevents state file conflicts
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Lesson 8 — Output Values

### What Outputs Are
- print values after terraform apply
- useful for getting IPs, DNS names, IDs of created resources
```hcl
output "ec2_public_ip" {
  value = aws_instance.my-server.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.my-server.id
}
```

### Use Outputs
```bash
terraform output               # show all outputs
terraform output ec2_public_ip # show specific output
```

---

## Lesson 9 — Variables in Terraform

### Input Variables
- make configs reusable and configurable
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "AWS region"
  type        = string
}
```

### Use Variables
```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "server" {
  instance_type = var.instance_type
}
```

### Pass Variables
```bash
# Command line
terraform apply -var="region=us-east-1"

# Variables file
terraform apply -var-file="prod.tfvars"
```

### terraform.tfvars
```hcl
region        = "us-east-1"
instance_type = "t2.micro"
```

---

## Lesson 10 — Environment Variables in Terraform

### Two Ways to Use Environment Variables
```bash
# AWS credentials via environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=us-east-1
```

### TF_VAR prefix
```bash
# Set Terraform variables via environment
export TF_VAR_region=us-east-1
export TF_VAR_instance_type=t2.micro
```

Any env var starting with `TF_VAR_` maps to a Terraform variable of the same name.

### Why Use Env Vars
- never hardcode credentials in .tf files
- never commit credentials to Git
- CI/CD pipelines set them automatically

---

## Lesson 11 — Create Git Repository for Terraform Project

### What Goes in .gitignore
─────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     │ File: .gitignore
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ # local .terraform dir
   2 │ .terraform/*
   3 │
   4 │ # tf state files
   5 │ *.tfstate
   6 │ *.tfstate.*
   7 │
   8 │ # tf variable files, may include sensitive data
   9 │ *.tfvars
─────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────





### Repo Structure
terraform-learn/
├── main.tf           # main resources
├── variables.tf      # variable declarations
├── outputs.tf        # output values
├── providers.tf      # provider config
├── terraform.tfvars  # variable values (gitignored)
└── .gitignore



---

## Lessons 12-14 — Automate Provisioning EC2 with Terraform


### What I Built





- tfvars
- main.tf populated with additional items
i # aws_default_route_table.main-rtb will be created
  + resource "aws_default_route_table" "main-rtb" {
      + arn                    = (known after apply)
      + default_route_table_id = "rtb-02ea9fb11031c9b17"
      + id                     = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + route                  = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + core_network_arn           = ""
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = "igw-068ff7cad0d1841b1"
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
      + tags                   = {
          + "Name" = "dev-main-rtb"
        }
      + tags_all               = {
          + "Name" = "dev-main-rtb"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.myapp-sg will be created
  + resource "aws_security_group" "myapp-sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8080
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8080
            },
          + {
              + cidr_blocks      = [
                  + "71.205.216.150/32",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "myapp-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "dev-sg"
        }
      + tags_all               = {
          + "Name" = "dev-sg"
        }
      + vpc_id                 = "vpc-0cd7e7c4e3476d3b9"
    }

Plan: 2 to add, 0 to change, 0 to destroy.
- Security Groups


### VPC Setup
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc" 
  }
}
### Security Group
resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

### EC2 Instance
resource "aws_instance" "myapp-server" {
  ami                     = data.aws_ami.latest-amazon-linux-image.id
  instance_type           = var.instance_type

  subnet_id               = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids  = [aws_security_group.myapp-sg.id]
  availability_zone       = var.avail_zone

  associate_public_ip_address = true 
  key_name                = "voip-lab-key"


- Automate provisioning Terraform 
- execute commands on server at the time of creation
- user_data = <<EOF
		#!/bin/bash/
		sudo yum update -y && sudo yum install -y docker
		sudo systemctl start docker 
		sudo usermod -aG docker ec2-user
		docker run -p 8080:80 nginx
		EOF
user@ip-10-0-10-218 ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                   NAMES
487cb046bb83   nginx     "/docker-entrypoint.…"   38 seconds ago   Up 36 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   heuristic_meninsky




### Files Created
main.tf
entry-script.sh

---

## Lesson 15 — Provisioners in Terraform

### What Provisioners Are
- run scripts on resources after creation
- used to install software, configure servers
- Terraform recommends avoiding them when possible
  use user_data or configuration management (Ansible) instead

### Types
```hcl
# remote-exec — run commands on remote server
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y nginx"
  ]
}

# local-exec — run commands on your local machine
provisioner "local-exec" {
  command = "echo ${aws_instance.server.public_ip} >> hosts.txt"
}

# file — copy files to remote server
provisioner "file" {
  source      = "script.sh"
  destination = "/tmp/script.sh"
}
```

---

## Lessons 16-18 — Modules in Terraform

### What Modules Are
- reusable packages of Terraform configuration
- like functions in programming
- keeps code DRY (Don't Repeat Yourself)

### Module Structure
modules/
└── webserver/
├── main.tf
├── variables.tf
└── outputs.tf




### Use a Module
```hcl
module "webserver" {
  source        = "./modules/webserver"
  instance_type = "t2.micro"
  region        = "us-east-1"
}
```

### Public Module Registry
```hcl
# Use community modules from registry.terraform.io
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

---

## Lessons 19-21 — Automate Provisioning EKS with Terraform

### What I Built
- Provisioned full EKS cluster on AWS using Terraform community modules
- Created VPC with public and private subnets across multiple availability zones
- Deployed managed node group with 3 t3.small worker nodes
- Used terraform-aws-modules/vpc/aws and terraform-aws-modules/eks/aws community modules
- Connected VPC module outputs directly to EKS module inputs
- All 62 resources created with single terraform apply
- Cluster took ~15 minutes to provision


---

## Lessons 22-24 — Complete CI/CD with Terraform

### What I Built
- Full CI/CD pipeline: Jenkins builds image → Terraform provisions EC2 → deploys app via docker-compose
- Jenkins provisions a fresh EC2 server on every pipeline run using Terraform
- App deployed via docker-compose with postgres on the new EC2 instance
- Pipeline waits for EC2 to initialize before deploying

- TWN-Terraform/java-maven-app/
	├── Jenkinsfile           ← full CI/CD pipeline
	├── Dockerfile            ← builds java-maven-app image
	├── server-cmds.sh        ← runs docker-compose on EC2
	├── docker-compose.yaml   ← starts app + postgres containers
	├── pom.xml               ← maven build config
	└── Terraform/
	├── main.tf           ← provisions VPC, subnet, SG, EC2
	├── variables.tf      ← input variables
	└── entry-script.sh   ← installs docker + docker-compose on EC2

### Jenkinsfile
### Jenkinsfile
```groovy
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
    stage("build app") {
      steps {
        script {
          echo 'building application jar...'
          sh 'mvn -f TWN-Terraform/java-maven-app/pom.xml clean package'
        }
      }
    }
    stage("build image") {
      steps {
        script {
          echo 'building docker image...'
          withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
            sh "docker build -t ${IMAGE_NAME} -f TWN-Terraform/java-maven-app/Dockerfile TWN-Terraform/java-maven-app"
            sh 'echo $PASS | docker login -u $USER --password-stdin'
            sh "docker push ${IMAGE_NAME}"
          }
        }
      }
    }
    stage("provision server") {
      environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret')
        TF_VAR_env_prefix     = 'test'
      }
      steps {
        script {
          dir('TWN-Terraform/java-maven-app/Terraform') {
            sh "terraform init"
            sh "terraform apply --auto-approve"
            EC2_PUBLIC_IP = sh(
              script: "terraform output ec2_public_ip",
              returnStdout: true
            ).trim()
          }
        }
      }
    }
    stage("deploy") {
      environment {
        DOCKER_CREDS = credentials('docker-hub-repo')
      }
      steps {
        script {
          echo "waiting for EC2 server to initialize"
          sleep(time: 90, unit: "SECONDS")
          echo 'deploying docker image to EC2...'
          echo "${EC2_PUBLIC_IP}"

          def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
          def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

          sshagent(['server-ssh-key']) {
            sh "scp -o StrictHostKeyChecking=no TWN-Terraform/java-maven-app/server-cmds.sh ${ec2Instance}:/home/ec2-user"
            sh "scp -o StrictHostKeyChecking=no TWN-Terraform/java-maven-app/docker-compose.yaml ${ec2Instance}:/home/ec2-user"
            sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
          }
        }
      }
    }               
  }
}
```

### entry-script.sh — EC2 Bootstrap
```bash
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# install docker-compose
sudo curl -SL "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### server-cmds.sh — Remote Deployment Script
```bash
#!/usr/bin/env bash
export IMAGE=$1
export DOCKER_USER=$2
export DOCKER_PWD=$3
echo $DOCKER_PWD | docker login -u $DOCKER_USER --password-stdin
docker-compose -f docker-compose.yaml up --detach
echo "success"
```

### docker-compose.yaml
```yaml
services:
  java-maven-app:
    image: ${IMAGE}
    ports:
      - 8080:8080
  postgres:
    image: postgres:16
    ports:
      - 5432:5432
    environment:
      - POSTGRES_PASSWORD=my-pwd
```

### Jenkins Credentials Required
| Credential ID | Type | Purpose |
|--------------|------|---------|
| `docker-hub-repo` | Username/Password | DockerHub push and pull |
| `jenkins_aws_access_key_id` | Secret Text | AWS Access Key for Terraform |
| `jenkins_aws_secret` | Secret Text | AWS Secret Key for Terraform |
| `server-ssh-key` | SSH Private Key | SSH into EC2 to deploy |

### Install Terraform Inside Jenkins Container
```bash
# SSH into Jenkins droplet
ssh root@<droplet-ip>

# Enter Jenkins container as root
docker exec -u 0 -it <container-id> /bin/bash

# Install dependencies
apt update && apt install -y gpg

# Add HashiCorp repo
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" | tee /etc/apt/sources.list.d/hashicorp.list

# Install terraform
apt update && apt install terraform -y

# Verify
terraform --version
```

### New SSH Key Pair Setup
- created new SSH key pair for this lesson
- added private key to Jenkins credentials as `server-ssh-key`
- Terraform provisions EC2 with the matching public key
- Jenkins uses `server-ssh-key` credential in sshagent to SSH into EC2

### Pipeline Flow
ode push → GitHub webhook → Jenkins
↓
Build JAR with Maven
↓
Build Docker image → push to DockerHub
↓
Terraform init + apply → provisions EC2 with VPC, SG, subnet
↓
entry-script.sh runs on EC2 boot:
installs docker + docker-compose
adds ec2-user to docker group
↓
Jenkins waits 90 seconds for EC2 to initialize
↓
Jenkins SCPs server-cmds.sh + docker-compose.yaml to EC2
↓
Jenkins SSHs into EC2 → runs server-cmds.sh
↓
server-cmds.sh:
logs into DockerHub
runs docker-compose up
↓
java-maven-app + postgres containers running on EC2 ✅








---

## Lesson 25 — Remote State in Terraform

### S3 Backend Setup
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### DynamoDB for State Locking
- prevents two people running terraform apply at same time
- creates a lock when apply starts
- releases lock when apply completes

---

## Lesson 26 — Terraform Best Practices

### Key Rules
- always use remote state in production
- always use state locking
- never commit .tfstate files to Git
- never commit .tfvars with secrets to Git
- use modules for reusable infrastructure
- use workspaces for multiple environments (dev/staging/prod)
- pin provider versions to avoid unexpected updates
- always run terraform plan before apply
- use consistent naming conventions across resources


---

## Key Concepts
- Terraform = infrastructure as code tool
- Provider = plugin for specific platform (AWS, GCP etc.)
- Resource = infrastructure Terraform creates and manages
- Data Source = read existing infrastructure
- State = Terraform's record of what it created
- Variables = make configs reusable
- Outputs = print values after apply
- Modules = reusable packages of Terraform config
- Remote State = store state in S3 for team collaboration
- TF_VAR_ = environment variable prefix for Terraform variables
- Terraform provisions infrastructure inside the Jenkins pipeline
- EC2 IP is dynamic — Terraform output captures it after apply
- `dir()` in Jenkinsfile changes working directory for Terraform commands
- entry-script.sh runs once on EC2 boot via user_data
- server-cmds.sh runs on every deploy via SSH
- docker-compose manages multiple containers as a stack


---

## Issues and Resolutions

[Duplicate resource name across .tf files
- Error: `Duplicate resource "aws_subnet" configuration`
- Cause: same resource name declared in both main.tf and main_old.tf
  Terraform reads ALL .tf files in a directory as one module
- Fix: delete or rename main_old.tf
  `mv main_old.tf main_old.tf.bak`
- Rule: resource names must be unique across ALL .tf files in same directory

### Reference to undeclared resource — dot vs underscore typo
- Error: `Reference to undeclared resource — A managed resource "aws" "vpc" has not been declared`
- Cause: used dots instead of underscores in resource reference
  `aws.vpc.myapp-vpc.default_route_table_id`
- Fix: use underscores in resource type, dots to chain attributes
  `aws_vpc.myapp-vpc.default_route_table_id`
- Rule: resource types always use underscores, attributes chain with dots

### Route table association referencing commented out resource
- Error: `Reference to undeclared resource "aws_route_table" "myapp-route-table"`
- Cause: aws_route_table was commented out but aws_route_table_association
  still referenced it
- Fix: either uncomment the route table or switch to aws_default_route_table
  and remove the association resource

### Wrong resource type name
- Error: `An argument named X is not expected here`
- Cause: used `aws_security` instead of `aws_security_group`
- Fix: `resource "aws_security_group" "myapp-sg"`
- Rule: resource type names are defined by the AWS provider — check docs

### Variable inside quotes in list
- Error: plan shows literal string "var.my_ip" instead of IP value
- Cause: variable wrapped in quotes inside list
  `cidr_blocks = ["var.my_ip"]`
- Fix: remove quotes — variable reference needs no quotes in a list
  `cidr_blocks = [var.my_ip]`

### Protocol value uppercase
- Error: `InvalidParameterValue — The value 'TCP' is not valid`
- Cause: AWS API expects lowercase protocol values
- Fix: `protocol = "tcp"` not `protocol = "TCP"`
- Rule: argument values are case sensitive — always check provider docs

### Variable declared in tfvars but not in configuration
- Error: `Value for undeclared variable "my_ip"`
- Cause: `my_ip = "x.x.x.x/32"` added to terraform.tfvars
  but no matching variable block in main.tf or variables.tf
- Fix: add variable declaration to your config
  `variable "my_ip" {}`
- Rule: every variable in tfvars must have a matching variable block
  in your .tf filesfill in as you go]

### aws_key_pair already exists in AWS
- Error: `InvalidKeyPair.Duplicate: The keypair already exists`
- Cause: added `aws_key_pair` resource block to create a key pair
  that already existed in AWS outside of Terraform
- Fix: remove the `aws_key_pair` resource block entirely
  reference the existing key name directly in the EC2 resource:
  `key_name = "voip-lab-key"`
- Also removed: `variable "my_public_key"` and `my_public_key` from tfvars
- Rule: if a resource already exists in AWS and wasn't created by Terraform
  either reference it directly by name or import it with `terraform import`
  never try to create it again with a resource block

### Variable inside quotes not interpolated
- Error: public key value was literal string "var.my_public_key" not actual key
- Cause: `public_key = "var.my_public_key"` — variable wrapped in quotes
- Fix: `public_key = var.my_public_key` — no quotes around variable reference
- Rule: quotes around a variable reference treat it as a literal string

### user_data script — nginx not running on EC2
- Cause: shebang line had extra slash `#!/bin/bash/`
- EC2 couldn't find the bash interpreter so entire script was skipped silently
- Fix: `#!/bin/bash` — no trailing slash
- Rule: always double check shebang line — silent failure if wrong

### gpg not installed in Jenkins container
- Error: `bash: gpg: command not found` when installing Terraform
- Fix: `apt update && apt install -y gpg` before running HashiCorp GPG command

### lsb_release not installed in Jenkins container
- Error: `bash: lsb_release: command not found`
- Cause: Jenkins container doesn't have lsb-release package
- Fix: hardcode Debian version instead
  `echo "deb [...] https://apt.releases.hashicorp.com bookworm main"`

### Wrong Terraform directory in Jenkinsfile
- Cause: `dir('TWN-Terraform/terraform-learn_1')` pointed at old location
- Fix: `dir('TWN-Terraform/java-maven-app/Terraform')`

### Wrong AWS secret credential ID
- Cause: Jenkins credential ID was `jenkins_aws_secret` not `jenkins-aws_secret_access_key`
- Fix: match credential ID exactly as named in Jenkins
  `credentials('jenkins_aws_secret')`
