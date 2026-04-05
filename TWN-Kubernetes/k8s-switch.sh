#!/bin/bash

ACTION=$1

case $ACTION in
  eks)
    aws eks update-kubeconfig --name eks-cluster-test --region us-east-1
    echo "✅ Switched to EKS cluster"
    kubectl config current-context
    ;;
  minikube)
    unset KUBECONFIG
    kubectl config use-context minikube
    echo "✅ Switched to Minikube"
    kubectl config current-context
    ;;
  linode)
    export KUBECONFIG=/Users/sharrods/Documents/Techworld-with-nana/TWN-Kubernetes/helm-chart-microservices/online-shop-microservices-kubeconfig.yaml
    echo "✅ Switched to Linode cluster"
    kubectl config current-context
    ;;
  unset)
    unset KUBECONFIG
    echo "✅ KUBECONFIG unset"
    ;;
  status)
    echo "Current context: $(kubectl config current-context)"
    echo "KUBECONFIG: ${KUBECONFIG:-~/.kube/config (default)}"
    ;;
  *)
    echo "Usage: k8s-switch [eks|minikube|linode|unset|status]"
    ;;
esac
