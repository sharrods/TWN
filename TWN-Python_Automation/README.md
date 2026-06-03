# Module 14 — Automation with Python

## What I Built

- automated EC2 health checks using Boto3 and schedule library
- tagged EC2 instances across multiple regions with environment labels
- retrieved EKS cluster information programmatically
- automated daily EBS volume snapshots for prod volumes
- automated cleanup of old snapshots keeping only most recent
- automated restore of EC2 volume from latest snapshot
- built website monitoring with automated email alerts and server restart

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

### What I Built

- first Boto3 script — listed all VPCs and their CIDR blocks
- learned how to navigate nested API responses

### Program

```python
import boto3

ec2_client = boto3.client('ec2', region_name="us-east-1")

all_available_vpcs = ec2_client.describe_vpcs()
vpcs = all_available_vpcs["Vpcs"]

for vpc in vpcs:
    print(vpc["VpcId"])
    cidr_block_assoc_sets = vpc["CidrBlockAssociationSet"]
    for assoc_set in cidr_block_assoc_sets:
        print(assoc_set)
```

### Common Boto3 Patterns

```python
import boto3

ec2_client = boto3.client("ec2", region_name="us-east-1")

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
- AWS groups instances into Reservations — always need double for loop

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

```
Create infrastructure  → Terraform
Automate tasks on it   → Python
```

---

## Lesson 5 — Health Check: EC2 Status Checks

### What I Built

- script that checks status of all EC2 instances
- prints instance state, instance status and system status
- runs every 5 seconds using schedule library

### Initial exploration

```python
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

### Final Program with Schedule

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

### What Each Part Does

- `describe_instance_status` = gets health of all instances
- `IncludeAllInstances=True` = includes stopped instances not just running
- `InstanceStatus` = software/OS level checks
- `SystemStatus` = underlying AWS hardware checks
- `schedule.every(5).seconds` = runs check every 5 seconds
- `while True` + `run_pending()` = keeps script running forever

---

## Lesson 6 — Write a Scheduled Task in Python

### What I Built

- same EC2 health check but changed interval to every 5 minutes
- demonstrates schedule library time intervals

### Schedule Library Options

```python
schedule.every(5).seconds.do(job)
schedule.every(5).minutes.do(job)
schedule.every().hour.do(job)
schedule.every().day.at("10:30").do(job)

while True:
    schedule.run_pending()
    time.sleep(1)
```

---

## Lesson 7 — Configure Server: Add Environment Tags to EC2

### What I Built

- tags all EC2 instances in us-east-1 with `environment=prod`
- tags all EC2 instances in second region with `environment=dev`
- uses both client and resource in same script

### Program

```python
import boto3

ec2_client_prod = boto3.client('ec2', region_name="us-east-1")
ec2_resource_prod = boto3.resource('ec2', region_name="us-east-1")

ec2_client_dev = boto3.client('ec2', region_name="us-east-1")
ec2_resource_dev = boto3.resource('ec2', region_name="us-east-1")

instance_ids_prod = []
instance_ids_dev = []

# get all instance IDs in prod region
reservations_prod = ec2_client_prod.describe_instances()['Reservations']
for res in reservations_prod:
    for ins in res['Instances']:
        instance_ids_prod.append(ins['InstanceId'])

# tag prod instances
ec2_resource_prod.create_tags(
    Resources=instance_ids_prod,
    Tags=[{'Key': 'environment', 'Value': 'prod'}]
)

# get all instance IDs in dev region
reservations_dev = ec2_client_dev.describe_instances()['Reservations']
for res in reservations_dev:
    for ins in res['Instances']:
        instance_ids_dev.append(ins['InstanceId'])

# tag dev instances
ec2_resource_dev.create_tags(
    Resources=instance_ids_dev,
    Tags=[{'Key': 'environment', 'Value': 'dev'}]
)
```

### What Each Part Does

- `describe_instances()['Reservations']` = AWS groups instances into reservations
- double for loop = first loop gets reservation, second gets instances inside it
- `create_tags` = applies tags to list of instance IDs
- client used to read (describe_instances)
- resource used to write (create_tags)

---

## Lesson 8 — EKS Cluster Information

### What I Built

- script that lists all EKS clusters in us-east-1
- prints status, endpoint, and version for each cluster

### Program

```python
import boto3

client = boto3.client('eks', region_name="us-east-1")
clusters = client.list_clusters()['clusters']

for cluster in clusters:
    response = client.describe_cluster(name=cluster)
    cluster_info = response['cluster']
    cluster_status = cluster_info['status']
    cluster_endpoint = cluster_info['endpoint']
    cluster_version = cluster_info['version']

    print(f"Cluster {cluster} status is {cluster_status}")
    print(f"Cluster endpoint: {cluster_endpoint}")
    print(f"Cluster version: {cluster_version}")
```

### What Each Part Does

- `list_clusters()` = returns list of cluster names
- `describe_cluster(name=cluster)` = gets full details for one cluster
- different service — uses `boto3.client('eks')` not `boto3.client('ec2')`

---

## Lesson 9 — Backup EC2 Volumes: Automate Creating Snapshots

### What I Built

- daily scheduled job that creates snapshots of all prod volumes
- filters volumes by tag to only backup tagged prod volumes

### Program

```python
import boto3
import schedule

ec2_client = boto3.client('ec2', region_name="us-east-1")

def create_volume_snapshots():
    volumes = ec2_client.describe_volumes(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['prod']
            }
        ]
    )
    for volume in volumes['Volumes']:
        new_snapshot = ec2_client.create_snapshot(
            VolumeId=volume['VolumeId']
        )
        print(new_snapshot)

schedule.every().day.do(create_volume_snapshots)

while True:
    schedule.run_pending()
```

### What Each Part Does

- `describe_volumes` with filter = only returns volumes tagged `Name=prod`
- `create_snapshot` = creates point-in-time backup of the volume
- `schedule.every().day` = runs backup once per day
- tag filter prevents accidentally snapshotting all volumes

---

## Lesson 10 — Automate Cleanup of Old Snapshots

### What I Built

- finds all prod volumes and their snapshots
- sorts snapshots by date newest first
- keeps the 2 most recent snapshots
- deletes everything older than the 2 most recent

### Program

```python
import boto3
from operator import itemgetter

ec2_client = boto3.client('ec2', region_name="us-east-1")

volumes = ec2_client.describe_volumes(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': ['prod']
        }
    ]
)

for volume in volumes['Volumes']:
    snapshots = ec2_client.describe_snapshots(
        OwnerIds=['self'],
        Filters=[
            {
                'Name': 'volume-id',
                'Values': [volume['VolumeId']]
            }
        ]
    )

    sorted_by_date = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse=True)

    for snap in sorted_by_date[2:]:
        response = ec2_client.delete_snapshot(
            SnapshotId=snap['SnapshotId']
        )
        print(response)
```

### What Each Part Does

- `describe_snapshots` with `OwnerIds=['self']` = only your own snapshots
- `sorted_by_date` = sorts newest first using itemgetter on StartTime
- `sorted_by_date[2:]` = slices list starting from index 2 — skips the 2 newest
- `delete_snapshot` = deletes all snapshots beyond the 2 most recent
- runs per volume — each prod volume keeps its own 2 most recent snapshots

---

## Lesson 11 — Automate Restoring EC2 Volume from Backup

### What I Built

- finds volume attached to a specific EC2 instance
- finds the most recent snapshot for that volume
- creates a new volume from that snapshot
- waits for volume to become available
- attaches the restored volume to the instance

### Program

```python
import boto3
from operator import itemgetter

ec2_client = boto3.client('ec2', region_name="us-east-1")
ec2_resource = boto3.resource('ec2', region_name="us-east-1")

instance_id = "i-0671d0fe02906a969"

# get volume attached to instance
volumes = ec2_client.describe_volumes(
    Filters=[
        {
            'Name': 'attachment.instance-id',
            'Values': [instance_id]
        }
    ]
)

instance_volume = volumes['Volumes'][0]

# get all snapshots for that volume
snapshots = ec2_client.describe_snapshots(
    OwnerIds=['self'],
    Filters=[
        {
            'Name': 'volume-id',
            'Values': [instance_volume['VolumeId']]
        }
    ]
)

# sort by StartTime descending to get latest
latest_snapshot = sorted(
    snapshots['Snapshots'],
    key=itemgetter('StartTime'),
    reverse=True
)[0]
print(latest_snapshot['StartTime'])

# create new volume from latest snapshot
new_volume = ec2_client.create_volume(
    SnapshotId=latest_snapshot['SnapshotId'],
    AvailabilityZone="us-east-1a",
    TagSpecifications=[
        {
            'ResourceType': 'volume',
            'Tags': [{'Key': 'Name', 'Value': 'prod'}]
        }
    ]
)

# wait for volume to be available then attach
while True:
    vol = ec2_resource.Volume(new_volume['VolumeId'])
    print(vol.state)
    if vol.state == 'available':
        ec2_resource.Instance(instance_id).attach_volume(
            VolumeId=new_volume['VolumeId'],
            Device='/dev/xvdb'
        )
        break
```

### What Each Part Does

- `describe_volumes` with `attachment.instance-id` filter = gets volumes for specific instance
- `describe_snapshots` with `OwnerIds=['self']` = only your own snapshots
- `sorted(...key=itemgetter('StartTime'), reverse=True)[0]` = newest snapshot first
- `itemgetter` = cleaner way to sort by dictionary key
- `while True` loop = polls volume state until available
- `attach_volume` = mounts restored volume to instance
- `/dev/xvdb` = device name for second volume

---

## Lesson 12 — Handling Errors with Try Except

### What I Built

- added error handling to Boto3 scripts using try/except
- handles both AWS-specific errors and general exceptions

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
- `Exception` catches everything else

---

## Lessons 13-15 — Website Monitoring

- Create a linode vm
- SSH Access = ssh -i ~/.ssh/{{ ssh-key }} root@74.207.228.174
- apt update
- install docker

### Add Docker's official GPG key:

apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

### Add the repository to Apt sources:

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

- Install docker
  apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
- Install nginx docker run -d -p 8080:80 nginx
- root@localhost:~# docker ps
  CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
  059194ef510e nginx "/docker-entrypoint.…" 11 seconds ago Up 11 seconds 0.0.0.0:8080->80/tcp, [::]:8080->80/tcp determined_galois
- Welcome to nginx!

### Install requests in venv

- ❯ source ~/Documents/Projects/Python/venv_openpyxl/bin/activate
- ❯ pip3 install requests

- ❯ which python3
- /Users/sharrods/Documents/Projects/Python/venv_openpyxl/bin/python3

### Check that it request works

- ❯ python3 ~/Documents/Techworld-with-nana/TWN-Python_Automation/monitor-website0.py
- <Response [200]>

### Added request.text

❯ python3 ~/Documents/Techworld-with-nana/TWN-Python_Automation/monitor-website0.py

```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy,
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Add logic to look at status code and send message back

- response = requests.get('http://74.207.228.174:8080/')
  if response.status_code == 200:
  print('Application is running successfully!')
  else:
  print('Applicatiion is Down. Please Fix it!!')

```
 python3 ~/Documents/Techworld-with-nana/TWN-Python_Automation/monitor-website0.py
 Application is running successfully!
```

import smtplib
import requests
import os

EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')

response = requests.get('http://74.207.228.174:8080/')
if False:
print('Application is running successfully!')
else:
print('Application is Down. Please Fix it!!') # send email to me
with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
smtp.ehlo()
smtp.starttls()
smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
msg = "Subject: SITE DOWN\nFix the issue!"
smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, msg )

### Added Errror handling and turned off nginx

- /Users/sharrods/Documents/Projects/Python/venv_openpyxl/bin/python3.14 /Users/sharrods/Documents/Techworld-with-nana/TWN-Python_Automation/monitor-website0.py
  Connection error happened: HTTPConnectionPool(host='74.207.228.174', port=8080): Max retries exceeded with url: / (Caused by ConnectTimeoutError(<HTTPConnection(host='74.207.228.174', port=8080) at 0x10fea7a10>, 'Connection to 74.207.228.174 timed out. (connect timeout=None)'))

Process finished with exit code 0

### Added function to handle message

def send_notification(email_msg):
with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
smtp.ehlo()
smtp.starttls()
smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
message = f"Subject: SITE DOWN\n{email_msg}"
smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)

### What I Built

- monitors a web application every 5 minutes
- sends email alert when site is down
- automatically restarts Docker container via SSH
- reboots entire Linode server if container restart fails
- uses environment variables for credentials — never hardcoded

### Program

```python
import requests
import smtplib
import os
import paramiko
import linode_api4
import time
import schedule

EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')
LINODE_TOKEN = os.environ.get('LINODE_TOKEN')

def restart_server_and_container():
    # restart linode server
    print('Rebooting the server...')
    client = linode_api4.LinodeClient(LINODE_TOKEN)
    nginx_server = client.load(linode_api4.Instance, 52236040)
    nginx_server.reboot()

    # wait for server to come back up then restart container
    while True:
        nginx_server = client.load(linode_api4.Instance, 52236040)
        if nginx_server.status == 'running':
            time.sleep(5)
            restart_container()
            break

def send_notification(email_msg):
    print('Sending an email...')
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.starttls()
        smtp.ehlo()
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        message = f"Subject: SITE DOWN\n{email_msg}"
        smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)

def restart_container():
    print('Restarting the application...')
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname='172.104.252.104', username='root', key_filename='/Users/nana/.ssh/id_rsa')
    stdin, stdout, stderr = ssh.exec_command('docker start ee6b82b80ecd')
    print(stdout.readlines())
    ssh.close()

def monitor_application():
    try:
        response = requests.get('http://172-104-252-104.ip.linodeusercontent.com:8080/')
        if response.status_code == 200:
            print('Application is running successfully!')
        else:
            print('Application Down. Fix it!')
            msg = f'Application returned {response.status_code}'
            send_notification(msg)
            restart_container()
    except Exception as ex:
        print(f'Connection error happened: {ex}')
        msg = 'Application not accessible at all'
        send_notification(msg)
        restart_server_and_container()

schedule.every(5).minutes.do(monitor_application)

while True:
    schedule.run_pending()
```

### What Each Part Does

- `os.environ.get()` = reads credentials from environment variables
- `requests.get()` = HTTP GET to check if site responds
- `response.status_code == 200` = site is healthy
- `smtplib.SMTP` = sends email via Gmail SMTP
- `smtp.starttls()` = encrypts the connection
- `paramiko` = SSH library for Python — connects to server and runs commands
- `ssh.exec_command('docker start ...')` = restarts Docker container remotely
- `linode_api4` = Linode SDK — reboots entire server if container restart fails
- two levels of recovery: container restart first, full server reboot if that fails

### Libraries Used

```bash
pip install requests
pip install paramiko       # SSH connections from Python
pip install linode-api4    # Linode cloud SDK
pip install schedule       # scheduled tasks
```

### Environment Variables Required

```bash
export EMAIL_ADDRESS=your@gmail.com
export EMAIL_PASSWORD=your-app-password
export LINODE_TOKEN=your-linode-token
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
- `OwnerIds=['self']` = filters to only your own AWS resources
- `itemgetter` = sort nested dictionaries by a specific key
- paramiko = SSH from Python — run commands on remote servers
- environment variables = how credentials should always be passed to scripts

---

## Issues and Resolutions

### terraform nested .git folder in python automation folder

- Cause: cloned or moved terraform folder into TWN-Python_Automation
  folder had its own .git making it a submodule
- Error: `modified: TWN-Python_Automation/terraform (modified content)`
- Fix: `rm -rf TWN-Python_Automation/terraform/.git`
  then `git add TWN-Python_Automation/terraform/`

### same files showing as both staged and modified

- Cause: ran `git add` then kept editing the files
  git stages a snapshot at the moment you add
  edits after that are not included until you add again
- Fix: `git add` the files again to pick up latest changes

### **pycache** showing as untracked

- Cause: Python creates **pycache** automatically when scripts run
  was never added to .gitignore
- Fix: `echo "__pycache__/" >> .gitignore`
