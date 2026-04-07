# TWN-Terraform
# Module 12 — Terraform

## What I Built
[fill in after completing module]

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
[fill in as you go]

### VPC Setup
[fill in as you go]

### Security Group
[fill in as you go]

### EC2 Instance
[fill in as you go]

### Files Created
[fill in as you go]

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
[fill in as you go]

### EKS Cluster Config
[fill in as you go]

### Node Group Config
[fill in as you go]

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

---

## Issues and Resolutions

