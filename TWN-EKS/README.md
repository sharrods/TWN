# TWN-EKS
# Module 11 — AWS EKS (Elastic Kubernetes Service)

## What I Built
- Created EKS cluster via AWS Console and eksctl
- Configured Cluster Autoscaler for automatic node scaling
- Deployed nginx with LoadBalancer to EKS
- Created Fargate profile for serverless pod scheduling
- Deployed to LKE (Linode) from Jenkins pipeline
- Built complete CI/CD pipeline: Jenkins → ECR → EKS
- Managed multiple cluster contexts using k8s-switch script

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

- Create EC2 IAM role for worker nodes with these policies:
    - AmazonEC2ContainerRegistryReadOnly
    - AmazonEKS_CNI_Policy
    - AmazonEKSWorkerNodePolicy
- Create node group and attach role


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
--region us-east-1 \
--nodegroup-name demo-nodes \
--node-type t2.micro \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3

2026-04-05 16:10:28 [ℹ]  eksctl version 0.225.0
2026-04-05 16:10:28 [ℹ]  using region us-east-1
2026-04-05 16:10:29 [ℹ]  setting availability zones to [us-east-1a us-east-1d]
2026-04-05 16:10:29 [ℹ]  subnets for us-east-1a - public:192.168.0.0/19 private:192.168.64.0/19
2026-04-05 16:10:29 [ℹ]  subnets for us-east-1d - public:192.168.32.0/19 private:192.168.96.0/19
2026-04-05 16:10:29 [ℹ]  nodegroup "demo-nodes" will use "" [AmazonLinux2023/1.32]



026-04-05 16:18:35 [ℹ]  creating addon: vpc-cni
2026-04-05 16:18:35 [ℹ]  successfully created addon: vpc-cni
2026-04-05 16:18:36 [ℹ]  creating addon: kube-proxy
2026-04-05 16:18:36 [ℹ]  successfully created addon: kube-proxy
2026-04-05 16:18:37 [ℹ]  creating addon: coredns
2026-04-05 16:18:37 [ℹ]  successfully created addon: coredns
2026-04-05 16:20:39 [ℹ]  building managed nodegroup stack "eksctl-demo-cluster-nodegroup-demo-nodes"
2026-04-05 16:20:39 [ℹ]  deploying stack "eksctl-demo-cluster-nodegroup-demo-nodes"




### Install eksctl
```bash
brew tap weaveworks/eap
brew install weaveworks/tap/eksctl
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
- We now have nodes on EKS from last lesson 
- ❯ kb get node
NAME                             STATUS   ROLES    AGE   VERSION
ip-192-168-11-219.ec2.internal   Ready    <none>   22m   v1.32.12-eks-f69f56f
ip-192-168-36-237.ec2.internal   Ready    <none>   22m   v1.32.12-eks-f69f56f

- add config file to jenkins 
    - jenkins@2be5c6b8fe98:~$ mkdir .kube
    - jenkins@2be5c6b8fe98:~$ exit
- On host you have to copy to docker container 
    - root@Jenkins-2vcpu-4gb-nyc1-01:~# docker cp config 2be5c6b8fe98:/var/jenkins_home/.kube/
      Successfully copied 3.58kB to 2be5c6b8fe98:/var/jenkins_home/.kube/

- kb get pod
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6cfb98644c-br895   1/1     Running   0          61s




### What Changes vs Module 9
- target is EKS cluster not single EC2
- need kubectl configured in Jenkins to talk to EKS
- need AWS credentials in Jenkins
- IAM cli tools was added with eksctl tool
     - root@2be5c6b8fe98:/# ls -lah /usr/local/bin/
	total 120M
	drwxr-xr-x 1 root root 4.0K Apr  5 22:51 .
	drwxr-xr-x 1 root root 4.0K Nov 17 00:00 ..
	-rwxr-xr-x 1 root root  52M Apr  5 22:51 aws-iam-authenticator
	-rwxr-xr-x 1 root root  13M Mar 18 12:41 git-lfs
	-rwxrwxr-x 1 root root 7.1K Mar 18 12:39 jenkins-support
	-rwxrwxr-x 1 root root 2.5K Mar 18 12:39 jenkins.sh
	-rwxr-xr-x 1 root root  56M Apr  5 00:30 kubectl






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
- install gettext-base
- use kubectl to create secret 
- 



---

## Lesson 7 — Deploy to LKE Cluster from Jenkins Pipeline (Bonus)

### What I Built
- Connected Jenkins pipeline to Linode LKE cluster
- Deployed nginx to LKE cluster from Jenkins using kubectl
- Verified pod running on Linode worker nodes

### Setup
- Created LKE cluster on Linode (3 nodes, $36/month, Atlanta GA)
- Downloaded kubeconfig from Linode dashboard
- Added full kubeconfig file to Jenkins as Secret File credential (lke-creds)
- Installed k8s-switch script to manage multiple cluster contexts

### Jenkinsfile
```groovy
pipeline {   
    agent any
    stages {
        stage("Build") {
            steps {
                script {
                    echo "Building Application...."
                }
            }
        }
        stage("build image") {
            steps {
                script {
                    echo "Building the image..."
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    echo 'deploying docker image...'
                    withKubeConfig([credentialsId: 'lke-creds', serverUrl: 'https://23cae765-beed-4004-bfdd-ce133bcb9bbd.us-southeast-1-gw.linodelke.net:443']) {
                        sh 'kubectl create deployment nginx-deployment --image=nginx'
                    }
                }
            }
        }               
    }
}
```

### Validation Commands
```bash
kb get pods
kb get pods -w
kb get deployments
kb describe deployment nginx-deployment
```

### Verified Output



---

## Lesson 8 — Jenkins Credentials Best Practices

- store AWS keys as Secret Text not username/password
- store kubeconfig as Secret File not plain text
- never hardcode credentials in Jenkinsfile
- use credentialsId references only
- AWS credentials set as environment variables in deploy stage only
  not globally — limits exposure


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
❯ kb get secret
NAME               TYPE                             DATA   AGE
aws-registry-key   kubernetes.io/dockerconfigjson   1      7s
my-registry-key    kubernetes.io/dockerconfigjson   1      53m
❯ kb get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/java-maven-app-5cd9c95584-bdrqp     1/1     Running   0          3m5s
pod/java-maven-app-5cd9c95584-tsg74     1/1     Running   0          3m2s
pod/nginx-deployment-6cfb98644c-br895   1/1     Running   0          129m

NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/java-maven-app   ClusterIP   10.100.106.146   <none>        80/TCP    4m45s
service/kubernetes       ClusterIP   10.100.0.1       <none>        443/TCP   4h55m

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/java-maven-app     2/2     2            2           4m45s
deployment.apps/nginx-deployment   1/1     1            1           129m

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/java-maven-app-5cd9c95584     2         2         2       3m5s
replicaset.apps/java-maven-app-78b446b65b     0         0         0       3m52s
replicaset.apps/java-maven-app-7d6d696db4     0         0         0       4m45s
replicaset.apps/nginx-deployment-6cfb98644c   1         1         1       129m



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


### Cleanup
```bash
kb delete deployment java-maven-app
kb delete deployment nginx-deployment
kb delete service java-maven-app
kb delete secret aws-registry-key
eksctl delete cluster --name demo-cluster --region us-east-1
aws ecr delete-repository --repository-name java-maven-app --force --region us-east-1
```




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
- envsubst = substitutes environment variables into YAML files before applying
- imagePullSecrets = how K8s authenticates to private registry to pull images
- t2.micro too small for EKS worker nodes — use t3.small minimum

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

### kubectl pointing at wrong cluster
- Error: `dial tcp: lookup BFBE8A6E13F8186F1B1B6DB7D085D396.gr7.us-east-1.eks.amazonaws.com: no such host`
- Cause: KUBECONFIG was pointing at old deleted EKS cluster in ~/.kube/config
- Fix: `k8 linode ~/Downloads/linode-kube-cluster-test-kubeconfig.yaml`
- Root cause: every new terminal session resets KUBECONFIG to ~/.kube/config default
- Permanent fix: `kubectl config use-context minikube --kubeconfig ~/.kube/config`
  so default context points to something that exists

### k8 linode switch not persisting between terminals
- Cause: `export KUBECONFIG` inside script only lives in script process not current shell
- Fix: changed alias to `source /usr/local/bin/k8s-switch` so exports stick in current session
- Added to ~/.zshrc: `alias k8='source /usr/local/bin/k8s-switch'`

### Jenkins pipeline failed — wrong LKE endpoint
- Error: `failed to create deployment` connecting to old Linode cluster endpoint
- Cause: Jenkinsfile had endpoint from previous Linode cluster that was deleted
- Wrong: `https://f8cdca95-5ea5-426d-9ef2-58783fc333ec.us-southeast-2-gw.linodelke.net`
- Fixed: `https://23cae765-beed-4004-bfdd-ce133bcb9bbd.us-southeast-1-gw.linodelke.net:443`
- Lesson: every new Linode cluster gets a new API endpoint URL
  update Jenkinsfile serverUrl when recreating clusters

### Jenkins credentials had old token
- Cause: new Linode cluster generates new kubeconfig with different token
- Fix: downloaded new kubeconfig from Linode dashboard
  updated Jenkins credential lke-creds with new kubeconfig file

### k8s-switch script linode case not exporting to current shell
- Cause: export in a subprocess cannot affect parent shell environment
- Fix: changed alias from execute to source
  `alias k8='source /usr/local/bin/k8s-switch'`

### t2.micro node group timed out
- Error: `exceeded max wait time for StackCreateComplete`
- Cause: t2.micro has 1GB RAM — too small to run EKS system pods
- Fix: use t3.small (2GB RAM) minimum for EKS worker nodes

### eksctl overwrote Linode kubeconfig
- Cause: KUBECONFIG env var was pointing at Linode file
  eksctl wrote EKS config into that file instead of ~/.kube/config
- Fix: always unset KUBECONFIG before running aws eks update-kubeconfig
  or specify explicit output file: `--kubeconfig ~/eks-kubeconfig.yaml`


### CloudFormation stuck on delete
- Cause: LoadBalancer service still running — blocked VPC deletion
- Fix: delete K8s services first then delete cluster
  `kb delete svc <name>` removes LB automatically

### Replicas exceeded node group max capacity
- Set replicas=20 but node group max=2
- Pods went Pending with: `NotTriggerScaleUp: max node group size reached`
- Fix: scale replicas back down `kb edit deployment nginx`
- Lesson: replicas must fit within node group capacity


### Secret name mismatch
- deployment.yaml referenced `my-registry-key`
- created secret as `aws-registry-key`
- Fix: update deployment.yaml imagePullSecrets to match secret name



