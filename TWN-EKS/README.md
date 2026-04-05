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
    - add
	eks.amazonaws.com/role-arn: arn:aws:iam::arn:aws:iam::{{ account ID }} :role/EKSServiceAccountRole
	cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
         - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/eks-cluster-test
	 - --balance-similar-node-groups
	 - --skip-nodes-with-system-pods=false
	 - image: registry.k8s.io/autoscaling/cluster-autoscaler:v1.32.7
	env:
            - name: AWS_REGION
              value: "us-east-1"

### Cluster Autoscaler Setup
- deployed cluster-autoscaler to kube-system namespace
- watches node groups and scales based on pod demand
- scales UP when pods are pending due to insufficient resources
- scales DOWN when nodes are underutilized

kb get deployment -n kube-system cluster-autoscaler
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
cluster-autoscaler   1/1     1            1           32s


- ❯ kbp -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE
aws-node-dpzx4                        2/2     Running   0          77m
aws-node-v7jn6                        2/2     Running   0          81m
cluster-autoscaler-54fc7774f9-7f284   1/1     Running   0          110s
coredns-cd49f47f8-9fl88               1/1     Running   0          3h50m
coredns-cd49f47f8-g2425               1/1     Running   0          3h50m
eks-node-monitoring-agent-b5lht       1/1     Running   0          81m
eks-node-monitoring-agent-cthmz       1/1     Running   0          77m
eks-pod-identity-agent-r95q6          1/1     Running   0          81m
eks-pod-identity-agent-vk66q          1/1     Running   0          77m
kube-proxy-4n5k8                      1/1     Running   0          81m
kube-proxy-d4b5t                      1/1     Running   0          77m
metrics-server-68dd5c6f99-8rzj7       1/1     Running   0          3h46m
metrics-server-68dd5c6f99-nl2c4       1/1     Running   0          3h46m

	 
I0404 20:15:13.975535       1 main.go:720] Cluster Autoscaler 1.32.7
I0404 20:15:14.081510       1 leaderelection.go:257] attempting to acquire leader lease kube-system/cluster-autoscaler...
I0404 20:15:14.092236       1 leaderelection.go:271] successfully acquired lease kube-system/cluster-autoscaler
I0404 20:15:14.092542       1 event_sink_logging_wrapper.go:48] Event(v1.ObjectReference{Kind:"Lease", Namespace:"kube-system", Name:"cluster-autoscaler", UID:"41695bc1-8c4b-4dc3-a263-a58a0e1ca8f1", APIVersion:"coordination.k8s.io/v1", ResourceVersion:"37638", FieldPath:""}): type: 'Normal' reason: 'LeaderElection' cluster-autoscaler-54fc7774f9-7f284 became leader


### Deploy NGINX Application Load balancer
- ❯ kbf nginx.yaml
deployment.apps/nginx created
service/nginx created

- Check nginx. 
192.168.26.173 - - [04/Apr/2026:20:49:55 +0000] "GET / HTTP/1.1" 200 896 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.2 Safari/605.1.15" "-"
192.168.26.173 - - [04/Apr/2026:20:50:26 +0000] "GET / HTTP/1.1" 200 896 "-" "curl/8.7.1" "-"

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

- Add dev as a namespace in yaml file
- create pod selection namespace on aws console 
- add key and value. profile and fargate
- add namespace dev
	❯ kb create ns dev
	namespace/dev created
- create/deploy first pod through fargate 

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

eksctl create cluster \
--name demo-cluster \
--version 1.32 \
--region eu-central-1 \
--nodegroup-name demo-nodes \
--node-type t2.micro \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3




### Install eksctl
```bash
brew tap weaveworks/eap
brew install weaveworks/tap/eksctl
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


### Replicas exceeded node group max capacity
- Set nginx replicas to 20 but autoscaling group max was set to 2 nodes
- Pods went into Pending state with error:
  `NotTriggerScaleUp: pod didn't trigger scale-up: 1 max node group size reached`
- Cluster autoscaler wanted to add nodes but hit the max limit
- Load balancer started rejecting requests because not enough healthy pods
- kubectl also lost connection because KUBECONFIG was pointing at wrong cluster

- Resolution:
  1. Fix kubeconfig: `aws eks update-kubeconfig --name eks-cluster-test --region us-east-1`
  2. Scale replicas back down: `kb edit deployment nginx` → change replicas to 1
  3. Cluster autoscaler scaled node back down automatically

- Lesson: always check your autoscaling group max before scaling replicas
  replicas cannot exceed what your nodes can handle
  cluster autoscaler cannot add nodes beyond the max group size
```






