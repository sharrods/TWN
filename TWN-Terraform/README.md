# TWN-Terraform
# Module 12 — Terraform

## What I Built

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

### Terraform Plan Output



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
- create new branch 
- feature/deploy-to-ec2-default-components

- ❯ git checkout -b feature/provisioners
Switched to a new branch 'feature/provisioners'

░▒▓    ~/Documents/Techworld-with-nana  on   feature/provisioners *1 ··






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
### What I Built
- Refactored flat main.tf into reusable modules
- Created subnet module handling VPC networking components
- Created webserver module handling EC2 and security group
- Parameterized everything through tfvars file
- Connected modules together through outputs and variables
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
  instance_type = "t3.micro"
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
- Created VPC with public and private subnets across multiple AZs
- Deployed managed node group with auto-scaling
- Connected VPC module outputs to EKS module inputs
- All infrastructure defined as code — no manual console clicks

terraform-learn-eks/
├── vpc.tf               # VPC module configuration
├── eks-cluster.tf       # EKS cluster module configuration
├── terraform.tfvars     # variable values (gitignored)
└── .terraform/          # downloaded modules (gitignored)

### vpc.tf — VPC Setup Using Community Module
```hcl
module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name            = "myapp-vpc"
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = data.aws_availability_zones.azs.names

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = 1
  }
}
```

### eks-cluster.tf — EKS Cluster Using Community Module
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.17.1"

  name               = "myapp-eks-cluster"
  kubernetes_version = "1.33"

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id     = module.myapp-vpc.vpc_id

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns                = {}
    eks-pod-identity-agent = { before_compute = true }
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
  }

  eks_managed_node_groups = {
    dev = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 3
    }
  }

  tags = {
    environment = "development"
    application = "myapp"
  }
}
```

### terraform.tfvars
```hcl
vpc_cidr_block             = "10.0.0.0/16"
private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidr_blocks  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
```

### What Each Section Does

#### VPC Module
- creates VPC, subnets, internet gateway, route tables, NAT gateway automatically
- public subnets = load balancers live here, accessible from internet
- private subnets = worker nodes live here, not directly reachable from internet
- NAT gateway = allows worker nodes in private subnet to pull Docker images
- single_nat_gateway = one NAT gateway saves cost (~$32/month each)
- azs = spreads subnets across all AZs in region for high availability
- kubernetes tags = required so EKS can discover which VPC and subnets to use

#### EKS Module
- creates control plane, IAM roles, KMS encryption, CloudWatch logs
- subnet_ids points to private subnets from VPC module output
- vpc_id references VPC module output
- addons = K8s system components installed automatically
    - coredns = internal cluster DNS
    - kube-proxy = network rules on each node
    - vpc-cni = pod networking
    - eks-pod-identity-agent = IAM permissions for pods
    - before_compute = true means addon installs before worker nodes join
- managed node group = AWS handles patching and updates of worker nodes
- enable_cluster_creator_admin_permissions = your AWS user gets kubectl admin access automatically

#### How Modules Connect

module outputs:
module.myapp-vpc.private_subnets → used by eks module subnet_ids
module.myapp-vpc.vpc_id          → used by eks module vpc_id
eks module creates:
62 resources total across VPC and EKS
###
excerpt from terraform apply 


Plan: 62 to add, 0 to change, 0 to destroy.
module.eks.module.eks_managed_node_group["dev"].aws_iam_role.this[0]: Creating...
module.myapp-vpc.aws_vpc.this[0]: Creating...
module.eks.aws_iam_role.this[0]: Creating...
module.eks.aws_cloudwatch_log_group.this[0]: Creating...
module.eks.aws_cloudwatch_log_group.this[0]: Creation complete after 1s [id=/aws/eks/myapp-eks-cluster/cluster]
module.eks.module.eks_managed_node_group["dev"].aws_iam_role.this[0]: Creation complete after 1s [id=dev-eks-node-group-20260408231620378900000001]
module.eks.aws_iam_role.this[0]: Creation complete after 1s [id=myapp-eks-cluster-cluster-20260408231620379100000002]
module.eks.module.eks_managed_node_group["dev"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]: Creating...
module.eks.module.eks_managed_node_group["dev"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]: Creating...
module.eks.module.eks_managed_node_group["dev"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]: Creating...
module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]: Creating...
module.eks.module.kms.data.aws_iam_policy_document.this[0]: Reading...
module.eks.module.kms.data.aws_iam_policy_document.this[0]: Read complete after 0s [id=2998215644]
module.eks.module.kms.aws_kms_key.this[0]: Creating...
module.eks.module.eks_managed_node_group["de


### Commands
```bash
terraform init      # downloads community modules from registry
terraform plan      # preview 62 resources being created
terraform apply     # takes 15-20 minutes — EKS control plane is slow
terraform destroy   # takes 15-20 minutes — destroys in reverse order
```

### Connect kubectl After Apply
```bash
aws eks update-kubeconfig --name myapp-eks-cluster --region us-east-1
kubectl get nodes
```

### Why Terraform Over eksctl For EKS
- eksctl = fast, good for learning, limited customization
- Terraform = full control, version controlled, reproducible
- Terraform manages VPC + EKS together as one apply
- eksctl only manages the cluster, not the surrounding infrastructure
- in production Terraform is the standard approach





❯ terraform state list

░▒▓    ~/Documents/Techworld-with-nana/TWN-Terraform/terraform-learn-eks  on   feature/eks *1 !1 ······················· at 06:04:35 PM  ▓▒░
❯


---

## Lessons 22-24 — Complete CI/CD with Terraform



### What I Built
[fill in as you go]

### Pipeline Flow
[fill in as you go]

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
- - child module = called by root with module {} block
- variables.tf in each module = what inputs it accepts
- never put resource blocks in both root and module — pick one place
- data source block in module needs its own providers.tf or inherits from root

---

## Issues and Resolutions

[cate resource name across .tf files
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

### Unsupported attribute on module output
- Error: `Can't access attributes on a primitive-typed value (string)`
- Cause: calling .id on a value that was already an ID string
- Fix: remove the extra .id — if output already returns ID use it directly

### Wrong attribute name on AMI output
- Error: `This object does not have an attribute named "ami_id"`
- Cause: used .ami_id instead of .id on AMI data source
- Fix: use data.aws_ami.latest-amazon-linux-image.id

### Duplicate aws_instance in root and module
- Cause: aws_instance resource left in root/main.tf after moving to webserver module
- Fix: remove aws_instance from root/main.tf — it should only live in webserver/main.tf

### Typo in argument name
- Error: `An argument named "private_subnet_tabs" is not expected`
- Cause: `tabs` instead of `tags`
- Fix: `private_subnet_tags`

### Missing closing quote in tag value
- Error: `Invalid character` on tag line
- Cause: `"kubernetes.io/role/internal-elb = 1` missing closing quote
- Fix: `"kubernetes.io/role/internal-elb" = 1`

### Nested .git folder blocking push
- Cause: cloned Nana's repo into TWN subfolder creating nested git repo
- Error: `You are not allowed to push code to this project`
- Fix: `rm -rf <cloned-folder>/.git` then push from TWN root
- Rule: always remove .git immediately after cloning into existing repo

### S3 Bucket backend failed; Error asking for confirmation
- Error: `Error asking for confirmation` 
-  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend.

- Added  `-migrate-state  -input=false`  
	- migrate-state: Automatically moves your local tfstate —> S3 
	- input=false: Disables all interactive prompts
	- Error: [31m│[0m [0m[1m[31mError: [0m[0m[1mCan't ask approval for state migration when interactive input is disabled.
		 [31m│[0m [0m
		 [31m│[0m [0mPlease remove the "-input=false" option and try again.[0m

- Fix: `terraform init -migrate-state -force-copy -input=false`







bashgit add TWN-Terraform/README.md
git commit -m "Add Lessons 19-21 EKS with Terraform README"
git push origin feature/eks
