# TWN-Prometheus

# Module 16 — Prometheus, Grafana & Alertmanager

## What I Built

- deployed microservices app on EKS and Linode LKE
- installed Prometheus monitoring stack using `kube-prometheus-stack` Helm chart
- accessed Prometheus, Grafana, and Alertmanager UIs via port-forward
- ran CPU and HTTP load tests to trigger metric spikes

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
