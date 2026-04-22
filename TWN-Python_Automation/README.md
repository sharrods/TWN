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



---

## Lesson 5 — Health Check: EC2 Status Checks

```
import boto3



ec2_client = boto3.client('ec2', region_name="us-east-1")
ec2_resource = boto3.resource('ec2', region_name="us-east-1")

reservations = ec2_client.describe_instances()
for reservation in reservations['Reservations']:
    instances = (reservation['Instances'])
    for instance in instances:
        print(f"Instance {instance['InstanceId']} is {instance['State']['Name']}")

statuses = ec2_client.describe_instance_status()
for status in statuses['InstanceStatuses']:
    ins_status = status['InstanceStatus']['Status']
    sys_status = status['SystemStatus']['Status']
    print(f"Instance {status['InstanceId']} status is {ins_status} and system status is {sys_status}")

```

### What I Built

### Program
```python
import boto3
import schedule

ec2_client = boto3.client('ec2', region_name="us-east-1")
ec2_resource = boto3.resource('ec2', region_name="us-east-1")


def check_instance_status():
    statuses = ec2_client.describe_instance_status(
        IncludeAllInstances=True
    )
    for status in statuses['InstanceStatuses']:
        ins_status = status['InstanceStatus']['Status']
        sys_status = status['SystemStatus']['Status']
        state = status['InstanceState']['Name']
        print(f"Instance {status['InstanceId']} is {state} with instance status {ins_status} and system status {sys_status}")
    print("#############################\n")


schedule.every(5).seconds.do(check_instance_status)

while True:
    schedule.run_pending()

```

---


### Schedule Library
```python
import schedule
import time

schedule.every(10).seconds.do(job)
schedule.every().hour.do(job)
schedule.every().day.at("10:30").do(job)

while True:
    schedule.run_pending()
    time.sleep(1)
```

---

## Lesson 7 — Configure Server: Add Environment Tags to EC2

### What I Built
[fill in after completing]

### Program
```python
# [fill in after completing]
```

---

## Lesson 8 — EKS Cluster Information

### What I Built
[fill in after completing]

### Program
```python
# [fill in after completing]
```

---

## Lesson 9 — Backup EC2 Volumes: Automate Creating Snapshots

### What I Built
[fill in after completing]

### Program
```python
# [fill in after completing]
```

---

## Lesson 10 — Automate Cleanup of Old Snapshots

### What I Built
[fill in after completing]

### Program
```python
# [fill in after completing]
```

---

## Lesson 11 — Automate Restoring EC2 Volume from Backup

### What I Built
[fill in after completing]

### Program
```python
# [fill in after completing]
```

---

## Lesson 12 — Handling Errors

### Error Handling with Boto3
```python
import boto3
from botocore.exceptions import ClientError

try:
    ec2_client.describe_instances()
except ClientError as e:
    print(f"AWS error: {e.response['Error']['Code']}")
    print(f"Message: {e.response['Error']['Message']}")
except Exception as e:
    print(f"Unexpected error: {e}")
```

- `ClientError` = AWS API returned an error
- always import from `botocore.exceptions`
- check `e.response['Error']['Code']` for specific error type

---

## Lessons 13-15 — Website Monitoring

### Lesson 13 — Scheduled Task to Monitor Application Health
[fill in after completing]

### Lesson 14 — Automated Email Notification
[fill in after completing]

### Lesson 15 — Restart Application and Reboot Server
[fill in after completing]

### Program
```python
# [fill in after completing]
```

---

## Key Concepts
- Boto3 = AWS SDK for Python — automate anything you can do in AWS console
- client = low level API access, returns dict
- resource = high level object oriented access
- credentials come from ~/.aws/credentials — never hardcode them
- Terraform = create infrastructure, Python = automate tasks on infrastructure
- schedule library = run Python functions on a timer
- ClientError = how AWS API errors surface in Python
- always navigate API responses by printing full response first

---

# Issues and Resolutions
