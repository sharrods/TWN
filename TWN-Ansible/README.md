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

## Lesson 5-9 — Ansible Playbooks

[ec2]
ec2-44-201-64-76.compute-1.amazonaws.com ansible_python_interpreter=/usr/bin/python3
ec2-44-199-249-34.compute-1.amazonaws.com ansible_python_interpreter=/usr/bin/python3

[ec2:vars]
ansible_ssh_private_key_file=~/.ssh/multi-cloud-key
ansible_user=ec2-user

---

## Lesson 8 — Ansible Variables

[fill in after completing]

---

## Lesson 9 — Ansible Conditionals

[fill in after completing]

---

## Lesson 10 — Ansible Loops

- Added register to show status
  TASK [debug] \***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***\*\*\***\*\*\*\*\*\*\***

```
ok: [ec2-3-91-209-227.compute-1.amazonaws.com] => {
    "msg": {
        "changed": true,
        "cmd": "ps aux | grep node",
        "delta": "0:00:00.013043",
        "end": "2026-04-24 12:43:22.873641",
        "failed": false,
        "msg": "",
        "rc": 0,
        "start": "2026-04-24 12:43:22.860598",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "root         787  0.0  0.0      0     0 ?        I<   11:30   0:00 [xfs-inodegc/nvm]\nec2-user   34510  0.1  5.6 655504 52712 ?        Sl   12:39   0:00 node server\nec2-user   35830  0.0  0.3 223000  3416 pts/1    S+   12:43   0:00 /bin/sh -c ps aux | grep node\nec2-user   35832  0.0  0.2 222336  2144 pts/1    S+   12:43   0:00 grep node",
        "stdout_lines": [
            "root         787  0.0  0.0      0     0 ?        I<   11:30   0:00 [xfs-inodegc/nvm]",
            "ec2-user   34510  0.1  5.6 655504 52712 ?        Sl   12:39   0:00 node server",
            "ec2-user   35830  0.0  0.3 223000  3416 pts/1    S+   12:43   0:00 /bin/sh -c ps aux | grep node",
            "ec2-user   35832  0.0  0.2 222336  2144 pts/1    S+   12:43   0:00 grep node"
        ]
    }
}

PLAY RECAP *********************************************************************************************************************************************************************************************************************************
ec2-3-91-209-227.compute-1.amazonaws.com : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

- show less info by using msg={{app_status.stdout_lines}}

```
TASK [debug] *******************************************************************************************************************************************************************************************************************************
ok: [ec2-3-91-209-227.compute-1.amazonaws.com] => {
    "msg": [
        "root         787  0.0  0.0      0     0 ?        I<   11:30   0:00 [xfs-inodegc/nvm]",
        "ec2-user   34510  0.0  5.6 655504 52712 ?        Sl   12:39   0:00 node server",
        "ec2-user   37096  0.0  0.3 223000  3384 pts/1    S+   12:47   0:00 /bin/sh -c ps aux | grep node",
        "ec2-user   37098  0.0  0.2 222336  2144 pts/1    S+   12:47   0:00 grep node"
    ]
}

PLAY RECAP *********************************************************************************************************************************************************************************************************************************
ec2-3-91-209-227.compute-1.amazonaws.com : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

---

## Lesson 11 — Project: Deploy Application

[fill in after completing]

---

## Lesson 13 — Ansible stat Module and Conditionals

### What I Built

- used stat module to check if a file or directory exists
- registered the result to a variable
- used `when` conditional to skip task if directory already exists
- used find module output to get dynamic file path for rename

### Pattern — Check Before Acting

```yaml
# Step 1 — check if path exists
- name: Check if nexus folder already exists
  stat:
    path: /opt/nexus
  register: stat_result

# Step 2 — only run if it doesn't exist
- name: Rename nexus folder
  shell: mv {{find_result.files[0].path}} /opt/nexus
  when: not stat_result.stat.exists
```

### What Each Part Does

- `stat` module = checks if file or directory exists on remote server
- `register: stat_result` = captures the output into a variable
- `stat_result.stat.exists` = boolean — true if path exists, false if not
- `when: not stat_result.stat.exists` = only runs task when folder does NOT exist
- `find_result.files[0].path` = dynamic path from find module output
  first result from find — the actual nexus versioned folder name

### Why This Matters

- idempotent = running playbook twice won't fail trying to rename again
- without the check — second run would fail because nexus folder already exists
- stat + when = standard Ansible pattern for conditional task execution

### Issues and Resolutions

#### stat module does not support raw params

- Error: `Action 'ansible.builtin.stat' does not support raw params`
- Cause: missing space after `path:` — YAML parsed it as raw param not key-value
- Wrong: `path:/opt/nexus`
- Fixed: `path: /opt/nexus`
- Rule: always space after colon in YAML key-value pairs

---

## Lessons 14-15 — Project: Deploy Nexus

### What I Built

- installed Java and net-tools on DigitalOcean droplet using Ansible
- downloaded and unpacked Nexus Repository Manager automatically
- created dedicated nexus user and group
- set file ownership on nexus folders
- configured and started Nexus as nexus user
- verified Nexus running with ps and netstat

### Project Structure

```
TWN-Ansible/
├── hosts                 ← inventory file
├── ansible.cfg           ← host key checking disabled
└── deploy-nexus.yaml     ← full nexus deployment playbook
```

### Final Playbook

```yaml
---
- name: Install java and net-tools
  hosts: nexus_server
  become: yes
  tasks:
    - name: Update apt repo and cache
      apt: update_cache=yes force_apt_get=yes cache_valid_time=3600
    - name: Install Java 8
      apt: name=openjdk-8-jre-headless
    - name: Install net-tools
      apt: name=net-tools

- name: Download and unpack Nexus installer
  hosts: nexus_server
  become: yes
  tasks:
    - name: Check nexus folder stats
      stat:
        path: /opt/nexus
      register: stat_result
    - name: Download Nexus
      get_url:
        url: https://download.sonatype.com/nexus/3/latest-linux-x86_64.tar.gz
        dest: /opt/
      register: download_result
      when: not stat_result.stat.exists
    - name: Untar Nexus installer
      unarchive:
        src: "{{download_result.dest}}"
        dest: /opt/
        remote_src: yes
      when: not stat_result.stat.exists
    - name: Find nexus folder
      find:
        paths: /opt
        pattern: "nexus-*"
        file_type: directory
      register: find_result
    - name: Rename nexus folder
      shell: mv {{find_result.files[0].path}} /opt/nexus
      when: not stat_result.stat.exists

- name: Create nexus user to own nexus folder
  hosts: nexus_server
  become: yes
  tasks:
    - name: Ensure group nexus exists
      group:
        name: nexus
        state: present
    - name: Create nexus user
      user:
        name: nexus
        group: nexus
    - name: Make nexus user owner of nexus folder
      file:
        path: /opt/nexus
        state: directory
        owner: nexus
        group: nexus
        recurse: yes
    - name: Make nexus user owner of sonatype-work folder
      file:
        path: /opt/sonatype-work
        state: directory
        owner: nexus
        group: nexus
        recurse: yes

- name: Start nexus with nexus user
  hosts: nexus_server
  become: True
  become_user: nexus
  tasks:
    - name: Create nexus.rc file
      file:
        path: /opt/nexus/bin/nexus.rc
        state: touch
        owner: nexus
        group: nexus
    - name: Set run_as_user nexus
      lineinfile:
        path: /opt/nexus/bin/nexus.rc
        regexp: '^#run_as_user=""'
        line: run_as_user="nexus"
    - name: Start nexus
      command: /opt/nexus/bin/nexus start

- name: Verify nexus running
  hosts: nexus_server
  tasks:
    - name: Check with ps
      shell: ps aux | grep nexus
      register: app_status
    - debug: msg={{app_status.stdout_lines}}
    - name: Wait one minute
      pause:
        minutes: 1
    - name: Check with netstat
      shell: netstat -plnt
      register: app_status
    - debug: msg={{app_status.stdout_lines}}
```

### What Each Play Does

#### Play 1 — Install Java and net-tools

- `apt update_cache` = refresh package list before installing
- `force_apt_get` = use apt-get not apt for better automation support
- `cache_valid_time=3600` = don't re-update if cache refreshed within last hour
- Java required for Nexus to run
- net-tools required for netstat verification at end

#### Play 2 — Download and Unpack

- `stat` module = checks if /opt/nexus already exists before downloading
- `when: not stat_result.stat.exists` = skip download and untar if already done
- `get_url` = downloads from URL to remote server directly
- `register: download_result` = captures download path for unarchive
- `find` = locates the versioned nexus folder (nexus-3.x.x)
- `shell mv` = renames versioned folder to /opt/nexus

#### Play 3 — Create nexus user

- dedicated user and group for security — nexus should not run as root
- `recurse: yes` = applies ownership to all files inside folder

#### Play 4 — Start Nexus

- `become_user: nexus` = run start command as nexus user not root
- `file state: touch` = creates nexus.rc if it doesn't exist
  newer Nexus versions (3.91+) don't ship with nexus.rc
- `lineinfile` = sets run_as_user in nexus.rc config file

#### Play 5 — Verify

- `ps aux | grep nexus` = confirms nexus process is running
- `pause: minutes: 1` = waits for Nexus to fully initialize
- `netstat -plnt` = confirms Nexus is listening on port 8081

### Key Modules Used

- `stat` = check if file/directory exists
- `get_url` = download file from URL to remote server
- `unarchive` = extract archive on remote server
- `find` = search for files/directories matching pattern
- `lineinfile` = add or modify a specific line in a file
- `file` = manage files and directories (create, ownership, permissions)
- `group` = manage Linux groups
- `user` = manage Linux users
- `pause` = wait before continuing
- `debug` = print variable output

### Issues and Resolutions

#### yum used on Ubuntu droplet

- Error: `Could not detect which major revision of dnf is in use`
- Cause: used yum module on Ubuntu — Ubuntu uses apt not yum
- Fix: use `apt` module for DigitalOcean Ubuntu droplets
- Rule: apt = Ubuntu/Debian, yum = Amazon Linux/RHEL

#### nexus.rc does not exist in newer Nexus versions

- Error: `Destination /opt/nexus/bin/nexus.rc does not exist`
- Cause: Nexus 3.91+ removed nexus.rc file
  older versions used it to set run_as_user
- Fix: create the file first with `file: state: touch` then write to it

#### stat_result skipped tasks leaving nexus incomplete

- Cause: /opt/nexus existed from previous failed run
  stat said it exists so download and untar were skipped
  but folder was empty or incomplete
- Fix: remove incomplete folder then rerun

```bash
  rm -rf /opt/nexus /opt/nexus-* /opt/sonatype-work /opt/*.tar.gz
```

#### hosts group not found — all plays skipped

- Error: `Could not match supplied host pattern, ignoring: nexus_server`
- Cause: playbook used `nexus_server` group but hosts file had `[webserver]`
- Fix: add `[nexus_server]` group to hosts file with the correct IP

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

### Playbook hosts group not found — service error misleading

- Error: `Could not find the requested service nginx: host`
- Cause: playbook had `hosts: webserver` but inventory group was `[droplet]`
  Ansible couldn't find the group so tried to use it as a hostname
  the `: host` in the error was Ansible treating the group name as part of the service name
- Fix: match `hosts:` in playbook to the group name in inventory file
- Rule: group name in playbook must exactly match group name in hosts file

### apt module fails on EC2 Amazon Linux

- Error: `No such file or directory: b'update'`
- Cause: used `apt` module on Amazon Linux EC2
  Amazon Linux uses yum/dnf not apt
  apt doesn't exist on the server
- Fix: use `yum` module for Amazon Linux EC2
- Rule: apt = Ubuntu/Debian, yum = Amazon Linux/RHEL

### yum module unsupported parameters

- Error: `Unsupported parameters for (ansible.legacy.dnf) module: cache_valid_time, force_yum_get`
- Cause: copied apt syntax into yum module
  cache_valid_time and force_yum_get are apt-only parameters
  Amazon Linux 2023 uses dnf under the hood — yum is an alias
- Fix: remove apt-only parameters, use only yum supported params
  change `pkg:` to `name:` for package list
- Rule: apt and yum have different parameter names — check docs for each

### Playbook hosts group not found — service error misleading

- Error: `Could not find the requested service nginx: host`
- Cause: playbook had `hosts: webserver` but inventory group was `[droplet]`
  Ansible couldn't find the group so tried to use it as a hostname
  the `: host` in the error was Ansible treating the group name as part of the service name
- Fix: match `hosts:` in playbook to the group name in inventory file
- Rule: group name in playbook must exactly match group name in hosts file

### apt module fails on EC2 Amazon Linux

- Error: `No such file or directory: b'update'`
- Cause: used `apt` module on Amazon Linux EC2
  Amazon Linux uses yum/dnf not apt
  apt doesn't exist on the server
- Fix: use `yum` module for Amazon Linux EC2
- Rule: apt = Ubuntu/Debian, yum = Amazon Linux/RHEL

### yum module unsupported parameters

- Error: `Unsupported parameters for (ansible.legacy.dnf) module: cache_valid_time, force_yum_get`
- Cause: copied apt syntax into yum module
  cache_valid_time and force_yum_get are apt-only parameters
  Amazon Linux 2023 uses dnf under the hood — yum is an alias
- Fix: remove apt-only parameters, use only yum supported params
  change `pkg:` to `name:` for package list
- Rule: apt and yum have different parameter names — check docs for each

### Task requires root — permission denied

- Error: `This command has to be run under the root user`
- Cause: connecting as ec2-user which doesn't have root privileges
  yum install requires root
- Fix: add `become: yes` to the play or task
  `become: yes` at play level applies to all tasks in that play
  `become: yes` at task level applies to one task only
- Rule: any task that installs software or modifies system files needs become: yes

### vars must be dictionary not list

- Error: `Vars in a Play must be specified as a dictionary`
- Cause: used list syntax with dashes for vars block
  older Ansible versions accepted both formats
  newer versions enforce dictionary syntax only
- Wrong: `vars:` with `- key: value` (list)
- Fixed: `vars:` with `key: value` (dictionary, no dashes)
- Rule: vars in a play are always key-value pairs, never a list

### YAML parsing error — indentation mismatch

- Error: `While parsing a block mapping did not find expected key`
- Cause: task dash `-` had 3 spaces instead of 4
  YAML is strict about indentation — one space off breaks parsing
- Fix: ensure all task dashes align at 4 spaces
- Rule: all tasks in a play must have consistent indentation

### Module indented incorrectly under task name

- Error: YAML parsing fails or module not recognized
- Cause: module name indented too far — appeared to be under `name:` not at same level
- Wrong:

```yaml
  - name: Untar nexus installer
        unarchive:
```

- Fixed:

```yaml
- name: Untar nexus installer
  unarchive:
```

- Rule: module name must align with `name:` — both at same indentation level
