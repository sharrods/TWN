
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

### Lesson 12
[fill in as you go]

---
- add mosquitto config-map 
- volumes added and mounted inside container
- config map and secret are volume types 
	- they are local volume type in kubernetes


### Lesson 13
- Statefule set: databases
- Stateless set: dont keep record; each request is new 
- sometimes they forward to a statefule application 
- Helm Charts and why they are used. 

### Build Helm Chart
- brew install helm
- deploy mongodb using helm
- 3 replicas using statefule set
- configure data persistence with linode's cloud storage 
- deploy UI client Mongo-Express
- Configure nginx-ingress
- Create Kubernetes on Linode 
- Downloda test-kubeconfig.yaml
    - Make into a environmet variable
- chomod 400 test-kubeconfig.yaml
- export KUBECONFIG=test-kubeconfig.yaml
    - ❯ kb get node
    NAME                            STATUS   ROLES    AGE   VERSION
    lke587503-860320-16aaba4e0000   Ready    <none>   14m   v1.35.1
    lke587503-860320-3786dba10000   Ready    <none>   15m   v1.35.1
- deploy mongdb stateful set
- helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
- ❯ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
 
❯ helm search repo bitnami/mongodb
NAME                   	CHART VERSION	APP VERSION	DESCRIPTION
bitnami/mongodb        	18.6.21      	8.2.6      	MongoDB(R) is a relational open source NoSQL da...
bitnami/mongodb-sharded	9.4.12       	8.0.13     	MongoDB(R) is an open source NoSQL database tha...

- Install chart
    - ❯ helm install mongodb --values helm-mongodb.yaml bitnami/mongodb
- Overrides
    - 
- deploy 
   - ❯ helm install mongodb --values helm-mongodb.yaml bitnami/mongodb
NAME: mongodb
LAST DEPLOYED: Fri Apr  3 11:44:03 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
CHART NAME: mongodb
CHART VERSION: 18.6.21
APP VERSION: 8.2.6

⚠ WARNING: Since August 28th, 2025, only a limited subset of images/charts are available for free.
    Subscribe to Bitnami Secure Images to receive continued support and security updates.
    More info at https://bitnami.com and https://github.com/bitnami/containers/issues/83267

** Please be patient while the chart is being deployed **

MongoDB&reg; can be accessed on the following DNS name(s) and ports from within your cluster:

    mongodb-0.mongodb-headless.default.svc.cluster.local:27017
    mongodb-1.mongodb-headless.default.svc.cluster.local:27017
    mongodb-2.mongodb-headless.default.svc.cluster.local:27017


❯ kba
NAME                    READY   STATUS    RESTARTS   AGE
pod/mongodb-0           1/1     Running   0          2m
pod/mongodb-1           1/1     Running   0          77s
pod/mongodb-2           0/1     Running   0          32s
pod/mongodb-arbiter-0   1/1     Running   0          2m

NAME                               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
service/kubernetes                 ClusterIP   10.128.0.1   <none>        443/TCP     38m
service/mongodb-arbiter-headless   ClusterIP   None         <none>        27017/TCP   2m
service/mongodb-headless           ClusterIP   None         <none>        27017/TCP   2m

NAME                               READY   AGE
statefulset.apps/mongodb           2/3     2m
statefulset.apps/mongodb-arbiter   1/1     2m


region		Attached To	Encryption	
pvc-26460eff71a947e9
Active
US, Atlanta, GA	10 GB	
lke587503-860320-16aaba4e0000
Not Encrypted	
pvc-3610ad75a2f64b27
Active
US, Atlanta, GA	10 GB	
lke587503-860320-16aaba4e0000
Not Encrypted	
pvc-d345dae4f4214ae0
Active
US, Atlanta, GA	10 GB	
lke587503-860320-3786dba10000
Not Encrypted	

- Deploy mongoexpress 
- ❯ kbf helm-mongo-express.yaml
deployment.apps/mongo-express created
service/mongo-express-service created
❯ kbp
NAME                            READY   STATUS              RESTARTS   AGE
mongo-express-fd8bc9dcf-7cgfm   0/1     ContainerCreating   0          5s
mongodb-0                       1/1     Running             0          9m32s
mongodb-1                       1/1     Running             0          8m49s
mongodb-2                       1/1     Running             0          8m4s
mongodb-arbiter-0               1/1     Running             0          9m32s
❯ kbl mongo-express-5747d566b9-9n2vx
error: error from server (NotFound): pods "mongo-express-5747d566b9-9n2vx" not found in namespace "default"
❯ kbl mongo-express-fd8bc9dcf-7cgfm
Waiting for mongodb-0.mongodb-headless:27017...
No custom config.js found, loading config.default.js
Welcome to mongo-express 1.0.2
------------------------


Mongo Express server listening at http://0.0.0.0:8081
Server is open to allow connections from anyone (0.0.0.0)
basicAuth credentials are "admin:pass", it is recommended you change this in your config.js!

- install nginx-ingress controller
    - ❯ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    "ingress-nginx" has been added to your repositories

    - helm install nginx-ingress ingress-nginx/ingress-nginx  --set controller.publishService.enabled=true
        NAME: nginx-ingress
	LAST DEPLOYED: Fri Apr  3 11:59:01 2026
	NAMESPACE: default
	STATUS: deployed
	REVISION: 1
	DESCRIPTION: Install complete
	TEST SUITE: None
	NOTES:
	The ingress-nginx controller has been installed.

  
- create ingress 
❯ kbf helm-ingress.yaml
Warning: annotation "kubernetes.io/ingress.class" is deprecated, please use 'spec.ingressClassName' instead
ingress.networking.k8s.io/mongo-express created
❯ kb get ingress
NAME            CLASS    HOSTS                                      ADDRESS   PORTS   AGE
mongo-express   <none>   139-144-164-154.ip.linodeusercontent.com             80      9s

- Scale down replicas to see if persistence is good when we spin back up
    - ❯ kb scale --replicas=0 statefulset/mongodb
        statefulset.apps/mongodb scaled
	- mongodb-2                                                 1/1     Terminating 
	- mongodb-1                                                 1/1     Terminating
	- mongodb-0                                                 1/1     Terminating 

❯ helm ls
NAME         	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART               	APP VERSION
mongodb      	default  	1       	2026-04-03 11:44:03.42698 -0600 MDT 	deployed	mongodb-18.6.21     	8.2.6
nginx-ingress	default  	1       	2026-04-03 11:59:01.727698 -0600 MDT	deployed	ingress-nginx-4.15.1	1.15.1


- Add them back
- kb scale --replicas=3 statefulset/mongodb
statefulset.apps/mongodb scaled
	- mongodb-0                                                 1/1     Running   0          2m8s
	- mongodb-1                                                 1/1     Running   0          102s
	- mongodb-2                                                 1/1     Running   0   


---
## Deploying images in Kubernetes from private repository

- create docker config secret
- configure deployment for my-app application 
- ❯ kbf deploying-images-from-private-docker-repo/my-app-deployment.yaml
deployment.apps/my-app created




### Deploying micro services
- ❯ export KUBECONFIG=/Users/sharrods/Documents/Techworld-with-nana/TWN-Kubernetes/helm-chart-microservices/online-shop-microservices-kubeconfig.yaml
- Create Kubernetes Cluster 
- ❯ kb get node
NAME                            STATUS   ROLES    AGE     VERSION
lke587532-860363-0d1ea1ad0000   Ready    <none>   3m10s   v1.35.1
lke587532-860363-18eb431f0000   Ready    <none>   2m57s   v1.35.1
lke587532-860363-3cabf9f50000   Ready    <none>   3m6s    v1.35.1

- Create namespace microservices and deploy
❯ kb create ns microservices
namespace/microservices created
❯ kbf config.yaml -n microservices
deployment.apps/emailservice created
service/emailservice created
deployment.apps/recommendationservice created
service/recommendationservice created
deployment.apps/productcatalogservice created
service/productcatalogservice created
deployment.apps/paymentservice created
service/paymentservice created
deployment.apps/currencyservice created
service/currencyservice created
deployment.apps/shippingservice created
service/shippingservice created
deployment.apps/adservice created
service/adservice created
deployment.apps/cartservice created
service/cartservice created
deployment.apps/redis-cart created
service/redis-cart created
deployment.apps/checkoutservice created
service/checkoutservice created
deployment.apps/frontend created
service/frontend created

- Get microservices and service
❯ kbp -n microservices
NAME                                     READY   STATUS    RESTARTS      AGE
adservice-66ff9975bc-2hsxg               1/1     Running   0             81s
adservice-66ff9975bc-ttxbj               1/1     Running   0             81s
cartservice-7b846c5895-9pwnm             1/1     Running   0             80s
cartservice-7b846c5895-g7zcr             1/1     Running   0             80s
checkoutservice-7f56b944b8-mrcdx         1/1     Running   0             80s
checkoutservice-7f56b944b8-v2wjd         1/1     Running   0             80s
currencyservice-5b4b4c9bd4-4hrtv         1/1     Running   0             81s
currencyservice-5b4b4c9bd4-mtx4s         1/1     Running   0             81s
emailservice-5d9876976c-ftqlg            0/1     Running   1 (31s ago)   83s
frontend-5f8d9468f4-l6788                1/1     Running   0             79s
frontend-5f8d9468f4-nck5f                1/1     Running   0             79s
paymentservice-696f47b5f6-4h29v          1/1     Running   0             81s
paymentservice-696f47b5f6-jj9js          1/1     Running   0             81s
productcatalogservice-594bc59f78-gm5b2   1/1     Running   0             82s
productcatalogservice-594bc59f78-m74jd   1/1     Running   0             82s
recommendationservice-f86c5884b-4l9kx    1/1     Running   0             82s
recommendationservice-f86c5884b-5f2z4    1/1     Running   0             82s
redis-cart-d45dfffc4-btpsv               1/1     Running   0             80s
redis-cart-d45dfffc4-pvcqg               1/1     Running   0             80s
shippingservice-6cb96df4c8-58ddz         1/1     Running   0             81s
shippingservice-6cb96df4c8-8dh7t         1/1     Running   0             81s
❯ kb svc -n microservices
error: unknown command "svc" for "kubectl"

Did you mean this?
	set
❯ kb get svc -n microservices
NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)        AGE
adservice               ClusterIP      10.128.244.3     <none>            9555/TCP       117s
cartservice             ClusterIP      10.128.59.135    <none>            7070/TCP       117s
checkoutservice         ClusterIP      10.128.119.15    <none>            5050/TCP       116s
currencyservice         ClusterIP      10.128.91.247    <none>            7000/TCP       118s
emailservice            ClusterIP      10.128.241.190   <none>            5000/TCP       119s
frontend                LoadBalancer   10.128.102.128   139.144.164.154   80:30457/TCP   116s
paymentservice          ClusterIP      10.128.118.133   <none>            50051/TCP      118s
productcatalogservice   ClusterIP      10.128.20.30     <none>            3550/TCP       119s
recommendationservice   ClusterIP      10.128.30.168    <none>            8080/TCP       119s
redis-cart              ClusterIP      10.128.221.60    <none>            6379/TCP       117s
shippingservice         ClusterIP      10.128.80.97     <none>            50051/TCP      118s


### Create shared helmchart
- helm create microservice
- change template files; Use {{ .Values.appName }}
- create helm service microservice
- helm install email service
    - ❯ helm ls
NAME        	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART             	APP VERSION
emailservice	default  	1       	2026-04-03 17:09:13.910609 -0600 MDT	deployed	microservice-0.1.0	1.16.0

❯ kbp
NAME                            READY   STATUS    RESTARTS   AGE
emailservice-778b6cfbdd-bwhwh   1/1     Running   0          5m25s
emailservice-778b6cfbdd-n84r9   1/1     Running   0          5m25s

### Install all 
- ❯ kbp
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-5f8b8889c9-kk8fd               1/1     Running   0          9s
adservice-5f8b8889c9-rw5w9               1/1     Running   0          9s
cartservice-548cc667f7-bnjjg             1/1     Running   0          14s
cartservice-548cc667f7-zsgnz             1/1     Running   0          14s
checkoutservice-d5cdb7ffd-qj9cp          1/1     Running   0          7s
checkoutservice-d5cdb7ffd-w5mnm          1/1     Running   0          7s
currencyservice-dbb475f87-gtln8          1/1     Running   0          13s
currencyservice-dbb475f87-qkzs9          1/1     Running   0          13s
emailservice-778b6cfbdd-bwhwh            1/1     Running   0          46m
emailservice-778b6cfbdd-n84r9            1/1     Running   0          46m
frontend-7c9459ffb6-cwjgt                1/1     Running   0          6s
frontend-7c9459ffb6-z8x9t                1/1     Running   0          6s
paymentservice-85566bc778-h6mdv          1/1     Running   0          12s
paymentservice-85566bc778-z96jq          1/1     Running   0          12s
productcatalogservice-549b86c956-cwdvt   1/1     Running   0          11s
productcatalogservice-549b86c956-dnqld   1/1     Running   0          11s
recommendationservice-6b74f8cb9f-p455k   1/1     Running   0          24m
recommendationservice-6b74f8cb9f-vm9rk   1/1     Running   0          24m
redis-cart-9795bb64c-6556r               1/1     Running   0          4m9s
redis-cart-9795bb64c-zxr2k               1/1     Running   0          4m9s
shippingservice-56c958dbf6-b5jtf         1/1     Running   0          10s
shippingservice-56c958dbf6-hsbcw         1/1     Running   0          10s

Uninstall everything. 
❯ ./uninstall.sh
release "rediscart" uninstalled
release "emailservice" uninstalled
release "cartservice" uninstalled
release "currencyservice" uninstalled
release "paymentservice" uninstalled
release "recommendationservice" uninstalled
release "productcatalogservice" uninstalled
release "shippingservice" uninstalled
release "adservice" uninstalled
release "checkoutservice" uninstalled
release "frontendservice" uninstalled

- Create helm files 
- install brew install helmfile
- helmfile sync  #Will install all 
- helmfile destroy  #Will remove all
DELETED RELEASES:
NAME                    NAMESPACE   DURATION
shippingservice                           1s
frontendservice                           1s
rediscart                                 1s
checkoutservice                           1s
productcatalogservice                     1s
paymentservice                            1s
emailservice                              1s
cartservice                               1s
currencyservice                           1s
recommendationservice                     1s
adservice                                 1s

### Lesson 12 — ConfigMap & Secret as Volume Types
- configmap and secret can be mounted as files inside container
- not just env variables — can be actual config files
- use case: mosquitto message broker needs config file not env var
- mounted as local volume type inside the pod
- add volume to spec and volumeMount to container

### Lesson 13 — StatefulSet
- StatefulSet = for databases and stateful apps
- Stateless = dont keep state, each request is brand new
- Stateless apps sometimes forward to stateful apps
- StatefulSet pods have stable identity — mongodb-0, mongodb-1, mongodb-2
- each pod gets its own persistent volume
- pods start and stop in order — not random like Deployment

### Lesson 14 — Managed Kubernetes (Helm + Linode)
- Created K8s cluster on Linode (LKE)
- downloaded kubeconfig and set as environment variable
```bash
chmod 400 test-kubeconfig.yaml
export KUBECONFIG=test-kubeconfig.yaml
kb get node
NAME                            STATUS   ROLES    AGE   VERSION
lke587503-860320-16aaba4e0000   Ready    <none>   14m   v1.35.1
lke587503-860320-3786dba10000   Ready    <none>   15m   v1.35.1
```

### Lesson 15-16 — Helm: Package Manager for Kubernetes
- Helm = package manager for K8s like brew for Mac
- Helm Chart = bundle of K8s YAML files packaged together
- instead of managing 10 separate YAML files use one chart
- can override default values with your own values.yaml

### Install and Setup
```bash
brew install helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/mongodb
```

### Deploy MongoDB with Helm
```bash
helm install mongodb --values helm-mongodb.yaml bitnami/mongodb
```
- 3 replicas using StatefulSet
- persistent storage via Linode volumes (PVC auto created)
- 3 x 10GB volumes created automatically

### Deploy Mongo Express
```bash
kbf helm-mongo-express.yaml
```

### Install Nginx Ingress Controller
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --set controller.publishService.enabled=true
```

### Test Persistence
```bash
# scale down to 0
kb scale --replicas=0 statefulset/mongodb

# scale back up
kb scale --replicas=3 statefulset/mongodb
# data was still there — persistence confirmed ✅
```

### Helm Commands
```bash
helm ls                    # list installed releases
helm install <name> <chart>
helm uninstall <name>
helm upgrade <name> <chart>
```

### Lesson 17 — Deploy from Private Docker Registry
- create docker config secret in K8s
- configure deployment to use imagePullSecrets
- K8s uses the secret to authenticate to private registry when pulling image
```bash
kbf deploying-images-from-private-docker-repo/my-app-deployment.yaml
deployment.apps/my-app created
```

### Lessons 21-22 — Microservices Deployment
- created new K8s cluster on Linode for microservices
- created namespace microservices
- deployed 11 services from single config.yaml
```bash
export KUBECONFIG=/Users/sharrods/Documents/Techworld-with-nana/TWN-Kubernetes/helm-chart-microservices/online-shop-microservices-kubeconfig.yaml

kb create ns microservices
kbf config.yaml -n microservices

kb get svc -n microservices
# frontend has external IP — accessible from browser
# all others are ClusterIP — internal only
```

### Lessons 23-24 — Helm Chart for Microservices + Helmfile
- created shared helm chart called microservice
- one chart used for all 11 services
- each service has its own values file e.g. email-service-values.yaml
- helmfile manages deploying all services at once
```bash
brew install helmfile

helmfile sync     # install all services
helmfile destroy  # remove all services
```

### Uninstall Script
```bash
./uninstall.sh
# uninstalls all helm releases at once
```

---

## Issues and Resolutions

### helm repo add missing name argument
- Error: `helm repo add requires 2 arguments`
- Cause: forgot to include repo name before URL
- Wrong: `helm repo add https://github.com/bitnami/...`
- Fixed: `helm repo add bitnami https://charts.bitnami.com/bitnami`

### helm install env var name required value
- Error: `containers[0].env[0].name: Required value`
- Cause: Helm template used `.key` but values file used `name`
- Wrong in template: `- name: {{ .key }}`
- Fixed in template: `- name: {{ .name }}`

### cannot reuse helm release name
- Error: `cannot reuse a name that is still in use`
- Cause: failed install left partial release behind
- Fix: `helm uninstall <name>` then reinstall

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
