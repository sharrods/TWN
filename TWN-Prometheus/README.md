# TWN-Prometheus

# Module 16 — Prometheus, Grafana & Alertmanager

## What I Built

- deployed microservices app on EKS and Linode LKE
- installed Prometheus monitoring stack using `kube-prometheus-stack` Helm chart
- accessed Prometheus, Grafana, and Alertmanager UIs via port-forward
- ran CPU and HTTP load tests to trigger metric spikes
- configured custom alert rules using PrometheusRule CRDs
- configured Alertmanager email receiver for notifications
- deployed Redis Exporter to scrape Redis metrics
- instrumented own application with Prometheus client library
- created ServiceMonitor to expose app metrics to Prometheus

---

## Technologies Used

- Prometheus
- Grafana
- Alertmanager
- Helm
- Kubernetes (EKS / Linode LKE)
- Redis Exporter
- Prometheus Client Library

---

## Architecture

```
Kubernetes Cluster (EKS or Linode LKE)
    ↓
kube-prometheus-stack (namespace: monitoring)
    ├── Prometheus        — scrapes metrics from targets
    ├── Grafana           — dashboards and visualization
    ├── Alertmanager      — routes alerts to receivers (email, Slack)
    └── Node Exporter     — exposes node-level metrics

online-shop namespace
    └── Microservices app — load-tested to generate metrics

Redis Exporter
    └── scrapes Redis metrics → exposes to Prometheus

Own Application
    └── instrumented with client library → ServiceMonitor → Prometheus
```

---

## Lessons 1-3 — Introduction and Setup

- Create eks cluster
  eksctl create cluster \
   --name monitoring-cluster \
   --region us-east-1 \
   --nodegroup-name monitoring-nodes \
   --node-type t3.micro \
   --nodes 3 \
   --nodes-min 2 \
   --nodes-max 4
- View Nodes
  ❯ kb get nodes
  NAME STATUS ROLES AGE VERSION
  ip-192-168-18-83.ec2.internal Ready <none> 62m v1.34.7-eks-40737a8
  ip-192-168-28-55.ec2.internal Ready <none> 62m v1.34.7-eks-40737a8
  ip-192-168-60-109.ec2.internal Ready <none> 62m v1.34.7-eks-40737a8
- View new nodes in linode
  NAME STATUS ROLES AGE VERSION
  lke599315-879082-18de831e0000 Ready <none> 7m50s v1.35.1
  lke599315-879082-5c3593280000 Ready <none> 7m52s v1.35.1
  lke599315-879082-632902f20000 Ready <none> 7m50s v1.35.1

- deploy services
  ❯ kbf config-microservices.yaml
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
  deployment.apps/checkoutservice created
  service/checkoutservice created
  deployment.apps/frontend created
  service/frontend created
  service/frontend-external created
  deployment.apps/redis-cart created
  service/redis-cart created

- Deploy prometheus using the helm chart

  - add helm repo first

  ```bash
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  ```

  ❯ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  "prometheus-community" has been added to your repositories

- Update helm
  `bash
helm repo update
`
  ❯helm repo update

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈

- Install namespace
  kb create namespace monitoring

- Install prometheus in monitoring namespace
  helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

- Login to grafana

### What is Prometheus

- open source monitoring and alerting toolkit
- scrapes metrics from targets on a pull model — targets expose `/metrics` endpoint
- stores time-series data locally
- query language: PromQL
- integrates with Alertmanager for notifications and Grafana for visualization

### How It Works

```
Target (app / exporter)
    → exposes /metrics endpoint
    ↓
Prometheus
    → scrapes on interval
    → stores as time-series
    → evaluates alert rules
    ↓
Alertmanager
    → receives firing alerts
    → routes to receiver (email, Slack, PagerDuty)
```

### kube-prometheus-stack

- Helm chart that bundles Prometheus, Grafana, Alertmanager, and exporters
- uses Prometheus Operator under the hood
- operator introduces CRDs — PrometheusRule, ServiceMonitor, PodMonitor
- CRDs let you manage Prometheus config as Kubernetes objects instead of config files

---

## Lessons 4-5 — Deploy Microservices App

### What I Built

- created Kubernetes cluster using liniode
- deployed online-shop microservices app into dedicated namespace
- verified app accessible via load balancer endpoint

### EKS Cluster Setup

```bash
eksctl create cluster
kubectl create namespace online-shop
kubectl apply -f ~/Demo-projects/Bootcamp/monitoring/config-microservices.yaml \
  -n online-shop
```

### Optional — Linode LKE

```bash
chmod 400 ~/Downloads/online-shop-kubeconfig.yaml
export KUBECONFIG=~/Downloads/online-shop-kubeconfig.yaml
```

### What Each Part Does

- `kubectl create namespace online-shop` = isolates app workloads from monitoring stack
- `kubectl apply -f config-microservices.yaml` = deploys all microservices in one command
- `chmod 400` = sets correct permissions on kubeconfig file before exporting
- `export KUBECONFIG` = points kubectl at Linode cluster instead of EKS

### Generate CPU traffic

### Load Testing — Trigger CPU Spike

```bash
# get frontend external IP first
kubectl get svc frontend-external -n online-shop

# deploy curl pod — use curlimages/curl, NOT radial/busyboxplus:curl (deprecated)
kubectl run curl-test --image=curlimages/curl -i --tty --rm -- sh

# inside pod — loop curl against Linode LoadBalancer external IP
for i in $(seq 1 10000)
do
  curl <frontend-external-EXTERNAL-IP> > test.txt
done
```

---

## Lessons 6-8 — Alert Rules

### What I Built

- added prometheus-community Helm repo
- installed kube-prometheus-stack into monitoring namespace
- verified all pods running
- accessed Prometheus, Grafana, and Alertmanager UIs via port-forward
  created PrometheusRule CRD to define custom alert rules
- wrote PromQL expression to detect high CPU load on nodes
- wrote PromQL expression to detect crash looping pods
- set severity labels and human-readable annotations for Alertmanager routing
- verified alert lifecycle: pending → firing → inactive using cpu stress test

### alert-rules.yaml

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: main-rules
  namespace: monitoring
  labels:
    app: kube-prometheus-stack
    release: monitoring
spec:
  groups:
    - name: main.rules
      rules:
        - alert: HostHighCpuLoad
          expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 50
          for: 2m
          labels:
            severity: warning
            namespace: monitoring
          annotations:
            description: "CPU load on host is over 50%\n Value = {{ $value }}\n Instance = {{ $labels.instance }}\n"
            summary: "Host has HIGH CPU Load"
        - alert: KubernetesPodCrashLooping
          expr: kube_pod_container_status_restarts_total > 5
          for: 0m
          labels:
            severity: critical
            namespace: monitoring
          annotations:
            description: "Pod {{ $labels.pod }} is crash looping\n Value = {{ $value }}"
            summary: "Kubernetes pod crash looping"
```

### Apply and Verify

```bash
# apply the rule
kubectl apply -f alert-rules.yaml

# verify PrometheusRule was created
kubectl get prometheusrule -n monitoring

# verify Prometheus picked up the rules (35 default + yours)
kubectl get configmap prometheus-monitoring-kube-prometheus-prometheus-rulefiles-0 -n monitoring -o yaml > rulefiles.yaml
```

### PromQL Expression — Why Not the Default

Nana's video uses `cluster:node_cpu:ratio_rate5m` which is a pre-aggregated recording rule.
This only exists on certain cluster setups and is not available on Linode LKE.

```promql
# Nana's version — does not work on Linode
cluster:node_cpu:ratio_rate5m{cluster="$cluster"}

# Working version — raw calculation, works on any cluster
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)
```

### What Each Part Does

- `apiVersion: monitoring.coreos.com/v1` = PrometheusRule is a CRD introduced by the Prometheus Operator
- `labels: app/release` = must match the Prometheus Operator selector — without these labels the rule gets ignored
- `groups` = rules are organized into named groups for logical separation
- `alert:` = correct field name — singular, not `alerts:` — typo will cause strict decoding error
- `HostHighCpuLoad` = fires when avg CPU usage across cores exceeds 50% for 2 continuous minutes
- `KubernetesPodCrashLooping` = fires immediately when any pod exceeds 5 restarts
- `for: 2m` = condition must hold for 2 minutes before firing — prevents false alarms on brief spikes
- `for: 0m` = fires instantly — crash looping is always actionable, no grace period needed
- `severity: warning` = routed by Alertmanager to warning-level receivers
- `severity: critical` = routed to critical receivers — highest priority
- `{{ $value }}` = injects actual metric value into alert message
- `{{ $labels.pod }}` = injects pod name into crash loop alert message

### Trigger CPU Spike — Verify Alert Fires

```bash
# run cpu stress test
kubectl delete pod cpu-test
kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 30s --metrics-brief

# pod will restart every 30s — that's expected, keeps stress going
kubectl get pod cpu-test

# watch alert in Prometheus UI
# http://localhost:9090/alerts
# lifecycle: inactive → pending (condition met) → firing (after for: 2m) → inactive (after pod deleted)

# clean up
kubectl delete pod cpu-test
```

### Alert Lifecycle

- `inactive` = PromQL expression not matching — CPU below threshold
- `pending` = expression matching but `for:` duration not yet elapsed
- `firing` = condition held for full duration — Alertmanager receives the alert
- `inactive` again = CPU drops below threshold after stress pod deleted

### Install Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
helm ls
```

> Chart: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

### Check Stack Pods

```bash
kubectl get all -n monitoring
```

### Access UIs

#### Prometheus

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring &
# http://localhost:9090
```

#### Grafana

```bash
kubectl port-forward svc/monitoring-grafana 8080:80 -n monitoring &
# http://localhost:8080
# user: admin
# pwd: prom-operator
```

#### Alertmanager

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093 &
# http://localhost:9093
```

### What Each Part Does

- `helm install monitoring` = release name is `monitoring` — used as prefix in all service names
- `kubectl port-forward svc/...` = tunnels cluster service port to localhost
- `&` = runs port-forward in background so terminal stays usable
- Grafana default password `prom-operator` = set by chart — change in production

### Load Testing — Trigger CPU Spike

```bash
# Deploy busybox for curling
kubectl run curl-test --image=radial/busyboxplus:curl -i --tty --rm

# Inside pod — loop curl against load balancer endpoint
for i in $(seq 1 10000)
do
  curl <your-loadbalancer-endpoint> > test.txt
done
```

#### CPU Stress Test

```bash
kubectl delete pod cpu-test
kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 60s --metrics-brief
```

- `curl-test` = generates HTTP traffic to spike request metrics
- `cpu-test` = generates CPU load to trigger CPU alert rules
- `--cpu 4` = spawns 4 CPU stress workers
- `--timeout 60s` = runs stress test for 60 seconds then exits

---

## Lessons 6-8 — Alert Rules

### What I Built

- created PrometheusRule CRD to define custom alert rules
- rules evaluate PromQL expressions on an interval
- firing alerts sent to Alertmanager

### PrometheusRule YAML

```yaml
# add PrometheusRule YAML here after completing lessons 6-8
```

---

## Lesson 10 — Alertmanager — Email Receiver

### What I Built

- configured Alertmanager to route firing alerts to email receiver
- customized alert routing and grouping
- verified end-to-end: cpu-test fired HostHighCpuLoad → Alertmanager → email received
- created Gmail app password and base64 encoded it as a Kubernetes secret
- created AlertmanagerConfig CRD to route firing alerts to Gmail

### Files

- `email-secret.yaml` — Kubernetes secret containing base64 encoded Gmail app password
- `alert-manager-configuration.yaml` — AlertmanagerConfig routing config to email receiver

### Create and Apply Email Secret

```bash
# generate base64 encoded app password
echo -n "" | base64

# apply secret
kubectl apply -f email-secret.yaml
kubectl get secret gmail-auth -n monitoring
```

### email-secret.yaml

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: gmail-auth
  namespace: monitoring
data:
  password:
```

### Apply AlertmanagerConfig

```bash
kubectl apply -f alert-manager-configuration.yaml
kubectl get alertmanagerconfig -n monitoring

# verify config-reloader picked up the change
kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 \
  -n monitoring -c config-reloader | tail -5
# look for: Reload triggered with a fresh timestamp
```

### To update and reload config

```bash
# edit alert-manager-configuration.yaml then reapply
kubectl apply -f alert-manager-configuration.yaml
# output will show "configured" not "created"
```

### Verify Alert Fired and Email Sent

```bash
# trigger cpu spike
kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 60s --metrics-brief

# watch alert in Prometheus
# http://localhost:9090/alerts
# pending → firing after for: 2m

# check Alertmanager API for active alerts
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093 &
# http://localhost:9093/api/v2/alerts
```

### Expected Alerts on Linode LKE

- `KubeControllerManagerDown` and `KubeSchedulerDown` will always fire on Linode
  Linode manages the control plane — controller-manager and scheduler are not exposed as scrape targets
  Prometheus cannot find them and fires critical alerts — this is expected noise on managed clusters
- `Watchdog` always fires — intentional heartbeat alert to confirm alerting pipeline is alive

### What Each Part Does

- Gmail app password = required when 2FA enabled — generate at myaccount.google.com → Security → App passwords
- `base64` encoding = Kubernetes secrets store sensitive data as base64 not plain text
- `AlertmanagerConfig` CRD = Kubernetes-native way to configure Alertmanager routing without editing raw config
- `config-reloader` sidecar = watches for secret changes and reloads Alertmanager config automatically
- receiver name format = `namespace/alertmanagerconfigname/receivername` — visible in Alertmanager API response

### Alertmanager Config

```yaml
# add alertmanager config YAML here after completing lesson 10
```

---

## Lessons 11-13 — Deploy Redis Exporter

### What I Built

- added prometheus-redis-exporter Helm chart
- configured exporter to scrape Redis metrics
- metrics exposed to Prometheus via ServiceMonitor

### Install Redis Exporter

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install redis-exporter prometheus-community/prometheus-redis-exporter \
  -f redis-values.yaml
```

### redis-values.yaml

```yaml
# add redis-values.yaml contents here after completing lesson 13
```

### What Each Part Does

- `prometheus-redis-exporter` = sidecar-style exporter that connects to Redis and exposes metrics at `/metrics`
- `redis-values.yaml` = configures Redis connection string and ServiceMonitor settings
- ServiceMonitor = tells Prometheus Operator which endpoints to scrape

---

## Lessons 15-16 — Monitor Own Application

### What I Built

- instrumented application with Prometheus client library
- exposed `/metrics` endpoint from app
- created ServiceMonitor to register app as a Prometheus scrape target
-

### Steps

```bash
# add ServiceMonitor YAML and instrumentation steps after completing lessons 15-16
```

---

## Key Concepts

- Prometheus = pull-based metrics collection system — scrapes `/metrics` endpoints on interval
- Grafana = visualization layer — connects to Prometheus as data source
- Alertmanager = alert routing — receives firing alerts from Prometheus and routes to receivers
- Helm chart = kube-prometheus-stack bundles all three plus exporters and CRDs
- PrometheusRule = Kubernetes CRD for defining alert rules — managed by Prometheus Operator
- ServiceMonitor = Kubernetes CRD that tells Prometheus Operator what to scrape
- exporter = adapter that exposes metrics from third-party systems (Redis, Node, etc.)
- PromQL = Prometheus query language — used in alert rules and Grafana panels
- port-forward = tunnels cluster service to localhost for local UI access
- namespace = monitoring stack lives in `monitoring`, app in `online-shop` — keep them isolated

---

## Issues and Resolutions

### Prometheus stack pods stuck in Pending — t3.micro pod limit

- Error: `0/3 nodes are available: 3 Too many pods`
- Cause: t3.micro instances have a hard AWS ENI-based pod limit of 4 pods per node
  3-node cluster = 12 pod ceiling total
  online-shop microservices deployment consumed all 12 slots before Prometheus stack could schedule
  kube-prometheus-stack requires significantly more pods than t3.micro cluster can accommodate
- Fix: tear down EKS cluster and switch to Linode LKE which has no comparable pod count ceiling
- Workaround if staying on EKS: delete online-shop deployment first, install Prometheus stack,
  then redeploy online-shop — but cluster will still be tight and unstable at t3.micro size
- Rule: t3.micro is insufficient for running both an app and a full monitoring stack simultaneously
  kube-prometheus-stack alone needs more headroom than a 3-node t3.micro cluster provides
  use t3.small minimum for EKS when running Prometheus — or use Linode LKE for bootcamp modules

### EKS teardown — prevent orphaned Load Balancer blocking CloudFormation delete

- Cause: if LoadBalancer services are still running when eksctl delete cluster is called,
  CloudFormation stack gets stuck waiting for the LB to be deleted
  this was a known issue from Module 11
- Fix: before running eksctl delete cluster, check for and remove all LoadBalancer services first
  kubectl get svc -A | grep LoadBalancer
  kubectl delete svc <service-name> -n <namespace>
  then run: eksctl delete cluster --name <your-cluster-name>
- Rule: always clear LoadBalancer services before tearing down EKS — orphaned LBs will block
  CloudFormation delete and require manual cleanup in the AWS console

### Access Grafana

#### You can no longer access grafana with default password. Followed instructions from fellow TWN member

#### Site: https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/#access-grafana

```bash
# Step 1 — get chart notes (shows full login instructions)
helm get notes monitoring -n monitoring

# Step 2 — decode admin password
kubectl get secret --namespace monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Step 3 — port-forward using pod name
export POD_NAME=$(kubectl get pods --namespace monitoring \
  -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring" \
  -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace monitoring port-forward $POD_NAME 3000
# http://localhost:3000
# user: admin
# pwd: output from base64 decode command above
```

### What Each Part Does

- `helm get notes` = prints chart instructions including how to retrieve credentials
- `jsonpath="{.data.admin-password}"` = extracts the base64-encoded password field from the secret
- `base64 --decode` = decodes the password to plain text
- `POD_NAME` = captures the full generated pod name dynamically — avoids hardcoding the hash suffix
- `port-forward $POD_NAME 3000` = tunnels pod port 3000 to localhost
  note: port-forward to pod directly instead of service — both work, pod is more explicit

### curl-test pod stuck in ImagePullBackOff — schema 1 image deprecated

- Error: `schema 1 image manifests are no longer supported: invalid argument`
- Cause: `radial/busyboxplus:curl` uses Docker schema 1 manifest format
  Kubernetes 1.35 (containerd) dropped support for schema 1 images
  Nana's README uses this image but it no longer works on modern clusters
- Fix: replace with `curlimages/curl` which uses schema 2 and is actively maintained

```bash
# wrong
kubectl run curl-test --image=radial/busyboxplus:curl -i --tty --rm
# correct
kubectl run curl-test --image=curlimages/curl -i --tty --rm -- sh
```

- Rule: always check image age when Nana's demos fail on pull
  older DockerHub images built before 2020 are likely schema 1 and will fail on k8s 1.24+
