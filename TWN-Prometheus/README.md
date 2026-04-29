# TWN-Prometheus

# Module 16 — Prometheus, Grafana & Alertmanager

Monitoring stack deployed on Kubernetes using the `kube-prometheus-stack` Helm chart. Covers metrics collection, visualization, alert rules, third-party exporters, and instrumenting your own application.

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

## Deploy Microservices App in EKS

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

---

## Deploy Prometheus Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

helm ls
```

> Chart: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

---

## Check Stack Pods

```bash
kubectl get all -n monitoring
```

---

## Access UIs

### Prometheus

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring &
# http://localhost:9090
```

### Grafana

```bash
kubectl port-forward svc/monitoring-grafana 8080:80 -n monitoring &
# http://localhost:8080
# user: admin
# pwd: prom-operator
```

### Alertmanager

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093 &
# http://localhost:9093
```

---

## Load Testing — Trigger CPU Spike

```bash
# Deploy busybox for curling
kubectl run curl-test --image=radial/busyboxplus:curl -i --tty --rm

# Inside pod — loop curl against load balancer endpoint
for i in $(seq 1 10000)
do
  curl <your-loadbalancer-endpoint> > test.txt
done
```

### CPU Stress Test

```bash
kubectl delete pod cpu-test
kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 60s --metrics-brief
```

---

## Alert Rules

<!-- add PrometheusRule YAML here after completing lessons 6-8 -->

---

## Alertmanager — Email Receiver

<!-- add alertmanager config YAML here after completing lesson 10 -->

---

## Deploy Redis Exporter

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update

helm install redis-exporter prometheus-community/prometheus-redis-exporter \
  -f redis-values.yaml
```

<!-- add redis-values.yaml contents here after completing lesson 13 -->

---

## Monitor Own Application

<!-- add ServiceMonitor and instrumentation steps after completing lessons 15-16 -->

---

## Issues and Resolutions

<!-- document as you complete the module -->
