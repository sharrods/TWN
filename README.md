# DevOps Bootcamp — TechWorld With Nana

Complete hands-on DevOps bootcamp covering every major tool in the modern DevOps stack. 16 modules, 59 demo projects, 251 commits.

**[Live Bootcamp Portfolio](https://sharrods.github.io/TWN/)** · **[Portfolio](https://sharrods.github.io)**

---

## Stats

| Metric | Count |
|--------|-------|
| Modules completed | 16 (Module 5–16) |
| Demo projects built | 59 |
| Cloud providers used | 3 (AWS, DigitalOcean, Linode) |
| Commits | 251 |

---

## Modules

| Module | Topic | Key Technologies |
|--------|-------|-----------------|
| 5 | Cloud & Infrastructure as a Service | DigitalOcean · Linux · Java · Gradle |
| 6 | Artifact Repository Manager | Nexus · Maven · Gradle |
| 7 | Containers with Docker | Docker · Docker Compose · MongoDB · ECR |
| 8 | CI/CD with Jenkins | Jenkins · Groovy · Shared Libraries · Webhooks |
| 9 | AWS Services | EC2 · ECR · IAM · AWS CLI · Docker Hub |
| 10 | Kubernetes | Minikube · Helm · Helmfile · Linode LKE · StatefulSets |
| 11 | Kubernetes on AWS (EKS) | EKS · eksctl · Fargate · kubectl |
| 12 | Infrastructure as Code | Terraform · AWS · S3 Remote State · Modules |
| 13 | Programming with Python | Python · GitLab API · Automation |
| 14 | Automation with Python | Boto3 · EC2 · EKS · EBS Snapshots · Monitoring |
| 15 | Configuration Management | Ansible · Roles · Dynamic Inventory · Vault · Jenkins Integration |
| 16 | Monitoring with Prometheus | Prometheus · Grafana · Alertmanager · Custom Exporters |

---

## Project Highlights

### CI/CD Pipeline (Modules 8–9)
Full Jenkins pipeline with dynamic versioning — increment version → build Java artifact → build Docker image → push to DockerHub/ECR → deploy to EC2 with Docker Compose → commit version update back to Git. Shared library extracted for reuse across pipelines.

### Kubernetes (Modules 10–11)
Deployed microservices application on Linode LKE and AWS EKS. Built shared Helm charts for all microservices. Set up Fargate profiles, cluster autoscaler, and multi-cluster kubeconfig switching. Jenkins → LKE and Jenkins → EKS full CD pipelines.

### Terraform + Ansible (Modules 12 + 15)
Provisioned complete AWS infrastructure with Terraform (VPC, EC2, EKS, S3 remote state). Configured servers with Ansible roles and dynamic EC2 inventory. Integrated both tools into a single Jenkins CI/CD pipeline — provision then configure in one run.

### Python Automation (Modules 13–14)
Boto3 scripts for EC2 health checks, EKS cluster monitoring, automated EBS snapshots and cleanup, environment tag management. Website monitoring with automatic restart and email alerting.

### Prometheus Monitoring (Module 16)
Deployed full Prometheus Operator stack on EKS via Helm. Configured alert rules for CPU thresholds and pod failures. Monitored third-party apps (Redis) with exporters. Instrumented a Node.js application with Prometheus client library.

---

## Repository Structure

Each module has its own folder with the demo project code:

```
TWN/
├── TWN-Docker/               # Module 7 — Docker projects
├── TWN-Jenkins/              # Module 8 — Jenkins pipelines
├── TWN-AWS/                  # Module 9 — AWS deployments
├── TWN-Kubernetes/           # Module 10 — K8s manifests and Helm charts
├── TWN-EKS/                  # Module 11 — EKS cluster configs
├── TWN-Terraform/            # Module 12 — Terraform IaC
├── TWN-Python_Basics/        # Module 13 — Python scripts
├── TWN-Python_Automation/    # Module 14 — Boto3 automation
├── TWN-Ansible/              # Module 15 — Ansible playbooks and roles
└── TWN-Prometheus/           # Module 16 — Monitoring stack
```

---

## Technologies

`Ansible` · `Ansible Vault` · `AWS` · `AWS CLI` · `AWS ECR` · `AWS EKS` · `Boto3` · `CloudFormation` · `DigitalOcean` · `Docker` · `Docker Compose` · `Docker Hub` · `eksctl` · `Fargate` · `Git` · `GitLab` · `Grafana` · `Groovy` · `Gradle` · `Helm` · `Helmfile` · `IAM` · `Java` · `Jenkins` · `Kubernetes` · `Linux` · `Linode LKE` · `Maven` · `MongoDB` · `Nexus` · `Node.js` · `Prometheus` · `Alertmanager` · `Python` · `Redis` · `S3` · `Terraform` · `VPC`

---

## Certification

Completed the TechWorld With Nana DevOps Bootcamp and applied for the **Certified DevOps Practitioner** digital badge via Credly.

---

## About

Built by **Sharrod Skinner** — Senior Voice Infrastructure Engineer with deep expertise in carrier-grade SIP, SBCs, and media systems. This bootcamp was completed alongside a production multi-cloud VoIP lab to apply DevOps tooling directly to voice infrastructure.

**[Multi-Cloud VoIP Lab](https://github.com/sharrods/multi-cloud-voip-lab)** · **[Portfolio](https://sharrods.github.io)**
