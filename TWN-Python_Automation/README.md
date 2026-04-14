# TWN-Python_Automation
# Module 14 — Automation with Python

## What I Built


import boto3

ec2_client = boto3.client('ec2', region_name="us-east-1")

all_available_vpcs = ec2_client.describe_vpcs()
vpcs = all_available_vpcs["Vpcs"]

for vpc in vpcs:
    print(vpc["VpcId"])
    cidr_block_assoc_sets = vpc["CidrBlockAssociationSet"]
    for assoc_set in cidr_block_assoc_sets:
        print(assoc_set)



---

## Lesson 1 — Introduction to Boto3

### What is Boto3
- Boto3 = AWS SDK for Python
- lets you interact with AWS services using Python code
- same things you do in AWS console or CLI — but automated in a script
- install: `pip install boto3`

---

## Lesson 2 — Install Boto3 and Connect to AWS

```python
import boto3

# connect to EC2 in us-east-1
ec2_client = boto3.client("ec2", region_name="us-east-1")
ec2_resource = boto3.resource("ec2", region_name="us-east-1")
```

### client vs resource
- `client` = low level, returns raw JSON/dict responses
- `resource` = high level, returns Python objects with attributes and methods
- use client when you need full API response
- use resource when you want cleaner object-oriented code

### AWS credentials
- Boto3 uses credentials from `~/.aws/credentials`
- same credentials configured with `aws configure`
- never hardcode credentials in your scripts

---

## Lesson 3 — Getting Familiar with Boto3

### Common Boto3 Patterns
```python
import boto3

ec2_client = boto3.client("ec2", region_name="us-east-1")

# list all VPCs
vpcs = ec2_client.describe_vpcs()
print(vpcs)

# list all EC2 instances
instances = ec2_client.describe_instances()
for reservation in instances["Reservations"]:
    for instance in reservation["Instances"]:
        print(instance["InstanceId"])
        print(instance["State"]["Name"])
```

### Navigating API Responses
- responses are nested dictionaries
- use print() to see the full structure first
- then drill down with `response["Key"]["NestedKey"]`

---

## Lesson 4 — Terraform vs Python

### When to Use Terraform
- provisioning infrastructure (create/destroy)
- infrastructure that needs state tracking
- reproducible environments
- VPCs, EC2, EKS, RDS

### When to Use Python/Boto3
- automation tasks (health checks, backups, cleanup)
- logic and decision making based on state
- scheduled tasks
- anything that reads state and acts on it

### Simple Rule
