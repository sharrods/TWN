
dule 10 — Container Orchestration with Kubernetes

## What I Built
- Deployed MongoDB and Mongo Express on local Minikube cluster
- Flow: MongoExpress (External Service) → MongoExpress → MongoDB (Internal Service) → MongoDB
- Created deployment, secret, configmap and service files
- Set up Ingress with Nginx for external access via hostname
- Configured Kubernetes Dashboard with Ingress

## Architecture
```
External Request → Ingress (dashboard.com)
    → Mongo Express Service (LoadBalancer :30000)
    → Mongo Express Pod
    → MongoDB Service (ClusterIP internal)
    → MongoDB Pod
```

---

## Lesson 1 — Intro to Kubernetes

### What Kubernetes Solves
- open source container orchestration tool
- manages containerized applications across multiple machines
- solves monolith to microservices problem
- High availability — no downtime
- scales horizontally on demand
- self-healing — auto restarts crashed containers
- rolling updates with zero downtime

---

## Lesson 2 — Main K8s Components

### Components
- Pod = smallest deployable unit, wraps container
- Deployment = manages Pod lifecycle and replicas (stateless apps)
- StatefulSet = for databases, each Pod has stable identity (stateful apps)
- Service = stable network endpoint to reach Pods
- ConfigMap = non-sensitive config data (plain text)
- Secret = sensitive data like passwords (base64 encoded)
- Ingress = routes external traffic by hostname or path
- Namespace = logical grouping of resources
- Volume = persistent storage

---

## Lesson 3 — Kubernetes Architecture

### Master Node (Control Plane)
- API Server = entry point for all kubectl commands
- etcd = key-value database, stores entire cluster state
    - critical to backup — lose etcd = lose cluster state
- Scheduler = picks which worker node to run new Pod on
- Controller Manager = watches cluster, fixes drift from desired state

### Worker Node
- Kubelet = agent on node, starts/stops containers, reports to API server
    - if kubelet crashes → node goes NotReady → pods rescheduled to healthy nodes
    - kubelet itself must be restarted at OS level
- Kube Proxy = handles networking, routes traffic to correct Pod
- Container Runtime = actually runs containers (Docker, containerd)

### Request Flow
```
kubectl apply -f config.yaml
    → API Server
    → saves to etcd
    → Scheduler picks node
    → Kubelet starts container
    → Kube Proxy sets up networking
```

---

## Lesson 4 — Minikube and kubectl Setup

### Minikube
- local single-node K8s cluster for dev/testing
- runs master and worker on one machine

### Commands
```bash
brew install minikube
minikube start
minikube status
```

### kubectl alias
```bash
alias kb=kubectl
```

---

## Lesson 5 — Main kubectl Commands
```bash
# get resources
kb get pods
kb get pods -o wide
kb get services
kb get all
kb get namespace

# apply and delete
kb apply -f <file.yaml>
kb delete -f <file.yaml>

# debug
kb describe pod <pod-name>
kb logs <pod-name>
kb exec -it <pod-name> -- /bin/bash
```

### apply vs create
- `kubectl apply` = create OR update — use this always
- `kubectl create` = create only — fails if already exists

---

## Lesson 6 — YAML Configuration File

### Structure
```yaml
apiVersion: apps/v1   # which K8s API
kind: Deployment      # resource type
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app     # finds pods with this label
  template:
    metadata:
      labels:
        app: my-app   # label put ON pods
    spec:
      containers:
      - name: my-app
        image: my-app:1.0
        ports:
        - containerPort: 8080
```

### apiVersion by resource
- Pod, Service, ConfigMap, Secret → `v1`
- Deployment, StatefulSet → `apps/v1`
- Ingress → `networking.k8s.io/v1`

### Labels
- how K8s components find each other
- Deployment finds Pods by matching labels
- Service finds Pods by matching labels

---

## Lesson 7 — Demo Project: MongoDB + Mongo Express

### Files Created
- `mysecret.yaml` — base64 encoded credentials
- `mymongo.yaml` — MongoDB deployment + ClusterIP service
- `mongo-configmap.yaml` — database URL
- `mongo-express.yaml` — Mongo Express deployment + LoadBalancer service

### Deploy Order — important
```bash
# secret must exist before deployment that references it
kb apply -f mysecret.yaml
kb apply -f mymongo.yaml
kb apply -f mongo-configmap.yaml
kb apply -f mongo-express.yaml
```

### Access Mongo Express
```bash
minikube service mongo-express-service
```
```
┌───────────┬───────────────────────┬─────────────┬───────────────────────────┐
│ NAMESPACE │         NAME          │ TARGET PORT │            URL            │
├───────────┼───────────────────────┼─────────────┼───────────────────────────┤
│ default   │ mongo-express-service │ 8081        │ http://192.168.49.2:30000 │
└───────────┴───────────────────────┴─────────────┴───────────────────────────┘
```

### ConfigMap vs Secret
- ConfigMap = plain text, for non-sensitive config like URLs
- Secret = base64 encoded, for passwords and tokens
- never put passwords in ConfigMap

---

## Lesson 8 — Namespaces
```bash
kb get namespace
NAME              STATUS   AGE
default           Active   4h44m
kube-node-lease   Active   4h44m
kube-public       Active   4h44m
kube-system       Active   4h44m
```

- `default` = where your resources go if no namespace specified
- `kube-system` = K8s internals, DNS, proxy — never deploy here
- `kube-public` = publicly accessible data
- `kube-node-lease` = node heartbeat info
```bash
kb apply -f file.yaml -n my-namespace
kb get pods -n kube-system
```

---

## Lesson 9 — Services

### Service Types
- ClusterIP = internal only, default, use for databases
- NodePort = external via node port 30000-32767, dev/testing only
- LoadBalancer = external via cloud LB, production use

### Key Points
- Services give Pods a stable network endpoint
- Pod IP changes when replaced — Service IP stays same
- Service finds Pods using label selectors

---

## Lesson 10 — Ingress

### What It Does
- routes external traffic by hostname or path
- single entry point for multiple services
- handles SSL/TLS termination
- needs Ingress Controller — Nginx most common

### Minikube Ingress Setup
```bash
minikube addons enable ingress
minikube dashboard

kb get ingress -n kubernetes-dashboard
NAME                CLASS   HOSTS           ADDRESS        PORTS   AGE
dashboard-ingress   nginx   dashboard.com   192.168.49.2   80      12m

# add to /etc/hosts
192.168.49.2 dashboard.com

minikube tunnel   # now dashboard.com works in browser
```

### Ingress vs LoadBalancer
- LoadBalancer = one per service, port based
- Ingress = one for all services, host/path based, centralized SSL

---

## Lesson 11 — Volumes

### Why Needed
- containers are ephemeral — data lost on restart
- volumes survive container restarts
- critical for databases

### Types
- emptyDir = temp storage, shared between containers in same Pod
- hostPath = mount host directory into Pod
- PersistentVolume (PV) = cluster-wide storage resource
- PersistentVolumeClaim (PVC) = Pod's request for storage

### PV and PVC Flow
```
Admin creates PV (actual storage)
    → Developer creates PVC (storage request)
    → K8s binds PVC to matching PV
    → Pod uses PVC as volume
```

---

## Lesson 12
[fill in as you go]

---




## Issues and Resolutions

### Mongo Express not accessible in browser
- minikube runs in VM so LoadBalancer has no real external IP
- fix: `minikube service mongo-express-service` creates tunnel

### Ingress ADDRESS showing blank
- ingress controller not enabled
- fix: `minikube addons enable ingress` then wait 2-3 min

### dashboard.com not resolving
- no local DNS entry for dashboard.com
- fix: add `192.168.49.2 dashboard.com` to `/etc/hosts`
- then run `minikube tunnel`

### Secret not found when Pod starts
- deployment applied before secret existed
- fix: always apply Secret first, then ConfigMap, then Deployment

### Pod stuck in Pending
- fix: `kb describe pod <name>` and check Events at bottom
