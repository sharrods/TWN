# TWN-EKS
# Module 11 — AWS EKS (Elastic Kubernetes Service)

## What I Built

---

## Lesson 1 — Container Services on AWS

### AWS Container Services
- ECS (Elastic Container Service) = AWS own container orchestration
- EKS (Elastic Kubernetes Service) = managed Kubernetes on AWS
- Fargate = serverless container runtime, no nodes to manage
- ECR = private container registry (already used in Module 9)

### ECS vs EKS
- ECS = AWS proprietary, simpler, less control
- EKS = standard Kubernetes, more complex, portable
- use EKS if you already know K8s or need to move between clouds
- use ECS if you are AWS only and want simpler setup

---

## Lesson 2 — Create EKS Cluster with Console

### What AWS Manages in EKS
- control plane (API server, etcd, scheduler)
- master node availability and updates

### What You Still Manage
- worker nodes (EC2 instances)
- node groups
- networking
- add-ons

### Steps
- Create IAM Role 
- Assign Rold To EKS cluster 
- Create Role (global) 
    -  eks-cluster-role

- Create VPC for worker nodes
    - 
- Create cloudformation template 
    - https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
- create EKS cluster 
	❯ aws eks update-kubeconfig --name eks-cluster-test
	Added new context arn:aws:eks:us-east-1:728635436537:cluster/eks-cluster-test to /Users/sharrods/Documents/Techworld-with-nana/TWN-Kubernetes/helm-chart-microservices/online-shop-microservices-kubeconfig.yaml

- Endpoint
	❯ kb cluster-info
	Kubernetes control plane is running at https://BFBE8A6E13F8186F1B1B6DB7D085D396.gr7.us-east-1.eks.amazonaws.com
	CoreDNS is running at https://BFBE8A6E13F8186F1B1B6DB7D085D396.gr7.us-east-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

	To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
- Create EC2 Roles for node group (Worker Nodes)
    - Permissions policy summary
    - Policy name 
	- AmazonEC2ContainerRegistryReadOnly
	- AmazonEKS_CNI_Policy
	- AmazonEKSWorkerNodePolicy
- Create auto-scaling group options. 

- Create a role for the auto-scaling group
    - 


### Key Terms
- Node Group = group of EC2 instances that act as worker nodes
- Managed Node Group = AWS handles patching and updates of nodes
- EKS Add-ons = extra components like CoreDNS, kube-proxy, VPC CNI

---

## Lesson 3 — Autoscaling in EKS

### Two Types of Autoscaling
- HPA (Horizontal Pod Autoscaler) = scales pods up/down based on CPU/memory
- Cluster Autoscaler = scales nodes up/down based on pod demand

### Difference
- HPA = more pods on existing nodes
- Cluster Autoscaler = more nodes when pods can't be scheduled

### Commands
```bash
# check HPA
kb get hpa

# describe autoscaler
kb describe hpa <name>
```

---

## Lesson 4 — Fargate Profile

### What is Fargate
- serverless compute for containers
- no EC2 nodes to manage
- AWS manages the underlying infrastructure
- you only define pods

### Fargate vs Node Groups
| | Node Groups | Fargate |
|-|-------------|---------|
| Infrastructure | You manage EC2 | AWS manages |
| Cost | Pay for nodes | Pay per pod |
| Control | More control | Less control |
| Setup | More complex | Simpler |

### When to Use Fargate
- don't want to manage nodes
- variable workloads
- dev/test environments

---

## Lesson 5 — Create EKS with eksctl

### Install eksctl
```bash
brew install eksctl
eksctl version
```

### Create Cluster
```bash
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name my-nodes \
  --node-type t3.micro \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3
```

### Check Cluster
```bash
eksctl get cluster
kb get node
```

### Delete Cluster
```bash
eksctl delete cluster --name my-cluster
```

### eksctl vs Console
- eksctl = faster, repeatable, scriptable
- Console = visual, good for first time setup

---

## Lesson 6 — Deploy to EKS from Jenkins Pipeline

### What Changes vs Module 9
- target is EKS cluster not single EC2
- need kubectl configured in Jenkins to talk to EKS
- need AWS credentials in Jenkins

### Jenkins Setup for EKS
- install kubectl in Jenkins container
- configure aws credentials in Jenkins
- update kubeconfig in pipeline

### Jenkinsfile Deploy Stage
```groovy
stage('deploy') {
    steps {
        script {
            echo 'deploying to EKS...'
            sh 'aws eks update-kubeconfig --name my-cluster --region us-east-1'
            sh 'kubectl apply -f kubernetes/deployment.yaml'
        }
    }
}
```

---

## Lesson 7 — Deploy to LKE from Jenkins (Bonus)
[fill in as you go]

---

## Lesson 8 — Jenkins Credentials Best Practices
[fill in as you go]

---

## Lesson 9 — Complete CI/CD with EKS and DockerHub

### Full Pipeline Flow
```
Code Push → GitHub Webhook
    → Jenkins
    → Build JAR (Maven)
    → Build Docker Image
    → Push to DockerHub
    → Update K8s deployment on EKS
    → EKS pulls image and deploys
```

---

## Lesson 10 — Complete CI/CD with EKS and ECR

### Full Pipeline Flow
```
Code Push → GitHub Webhook
    → Jenkins
    → Build JAR (Maven)
    → Build Docker Image
    → Push to ECR
    → Update K8s deployment on EKS
    → EKS pulls from ECR and deploys
```

### ECR vs DockerHub for EKS
- ECR = same AWS account, IAM auth, no rate limits
- DockerHub = external, rate limits, separate credentials
- ECR is preferred for production EKS deployments

---

## Key Concepts
- EKS = AWS managed Kubernetes control plane
- eksctl = CLI tool to create and manage EKS clusters
- AWS manages master nodes, you manage worker nodes
- Node Group = EC2 instances acting as K8s worker nodes
- Fargate = serverless, no nodes to manage, pay per pod
- HPA = scales pods, Cluster Autoscaler = scales nodes
- Jenkins needs kubectl + AWS credentials to deploy to EKS
- ECR preferred over DockerHub for production EKS

---

## Issues and Resolutions
[document as you go]
