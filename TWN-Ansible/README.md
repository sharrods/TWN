# TWN-Ansible

# Module 15 — Configuration Management with Ansible

## What I Built

- provisioned 2 DigitalOcean droplets and 2 AWS EC2 instances as managed nodes
- installed Ansible on local Mac (control node)
- configured SSH access from local machine to all servers
- connected Ansible to all servers using inventory file
- disabled host key checking via ansible.cfg
- ran ad-hoc commands and playbooks to configure remote servers

## Architecture

```
Local Mac (Ansible control node)
    ↓ SSH
DigitalOcean Droplet 1 (157.245.242.146)
DigitalOcean Droplet 2 (157.230.180.203)
AWS EC2 Instance 1
AWS EC2 Instance 2
```

---

## Lesson 1-3 — Introduction and Setup

### What is Ansible

- open source configuration management and automation tool
- agentless — no software installed on managed nodes
- uses SSH to connect to remote servers
- tasks defined in YAML playbooks
- idempotent — running same playbook twice gives same result

### How It Works

```
Control Node (your Mac)
    → reads inventory file (which servers to manage)
    → reads playbook (what to do)
    → connects via SSH
    → executes tasks on managed nodes
    → reports results
```

### Install Ansible

```bash
pip install ansible
ansible --version
```

---

## Lesson 4 — Ansible Inventory and Ad-Hoc Commands

### What I Built

- created inventory file with 2 DigitalOcean droplets and 2 AWS EC2 instances
- grouped servers under `[droplet]` group
- set SSH credentials as group variables
- verified connectivity with ping module using both IP and DNS name

### Inventory File (hosts)

```ini
[droplet]
157.245.242.146
157.230.180.203

[droplet:vars]
ansible_ssh_private_key_file=~/.ssh/digitalocean
ansible_user=root
```

### ansible.cfg

```ini
[defaults]
host_key_checking = False
```

- disables SSH host key checking
- prevents `Are you sure you want to connect?` prompt on first connection
- required when connecting to new servers automatically
- put in same directory as your playbooks and hosts file

### Verify Connectivity

```bash
# ping all hosts
ansible all -i hosts -m ping

# ping specific group
ansible droplet -i hosts -m ping

# ping using DNS name
ansible all -i hosts -m ping
```

### Verified Output

```
157.230.180.203 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
157.245.242.146 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Inventory Concepts

- `[droplet]` = group name — can target by name in commands
- `[droplet:vars]` = variables applied to all hosts in group
- `ansible_ssh_private_key_file` = path to private key for SSH
- `ansible_user` = user to SSH in as
- `all` = targets every host in inventory
- `-m ping` = runs ping module, tests SSH connectivity
- hosts can be listed by IP or DNS name

---

## Lesson 5 — Ansible Playbooks

[fill in after completing]

---

## Lesson 6 — Ansible Modules

[fill in after completing]

---

## Lesson 7 — Collections in Ansible

[fill in after completing]

---

## Lesson 8 — Ansible Variables

[fill in after completing]

---

## Lesson 9 — Ansible Conditionals

[fill in after completing]

---

## Lesson 10 — Ansible Loops

[fill in after completing]

---

## Lesson 11 — Project: Deploy Application

[fill in after completing]

---

## Key Concepts

- Ansible = agentless configuration management tool
- control node = machine running Ansible (your Mac)
- managed node = server being configured (droplets, EC2)
- inventory = file listing servers Ansible manages
- playbook = YAML file defining tasks to run
- module = built-in Ansible function (ping, apt, copy, service etc.)
- ad-hoc command = one-off command without a playbook
- idempotent = running same playbook twice produces same result
- group = logical grouping of hosts in inventory
- group vars = variables applied to all hosts in a group
- ansible.cfg = Ansible configuration file
- host_key_checking = False = skip SSH fingerprint verification

---

## Issues and Resolutions

[document as you go]
