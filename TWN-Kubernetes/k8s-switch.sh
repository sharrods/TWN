#!/bin/bash

ACTION=$1

case $ACTION in
  eks)
    CLUSTER_NAME=$2
    REGION=${3:-us-east-1}
    if [ -z "$CLUSTER_NAME" ]; then
      echo "Usage: k8 eks <cluster-name> [region]"
      echo "Example: k8 eks demo-cluster us-east-1"
      exit 1
    fi
    aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
    echo "✅ Switched to EKS cluster: $CLUSTER_NAME in $REGION"
    kubectl config current-context
    ;;
  minikube)
    unset KUBECONFIG
    kubectl config use-context minikube
    echo "✅ Switched to Minikube"
    kubectl config current-context
    ;;
  linode|lke|digitalocean|do)
    KUBECONFIG_FILE=$2
    if [ -z "$KUBECONFIG_FILE" ]; then
      echo "Usage: k8 linode <path-to-kubeconfig>"
      echo "Example: k8 linode ~/Downloads/my-cluster-kubeconfig.yaml"
      exit 1
    fi
    if [ ! -f "$KUBECONFIG_FILE" ]; then
      echo "❌ File not found: $KUBECONFIG_FILE"
      exit 1
    fi
    export KUBECONFIG=$KUBECONFIG_FILE
    echo "✅ Switched to cluster using: $KUBECONFIG_FILE"
    kubectl config current-context
    ;;
  unset)
    unset KUBECONFIG
    echo "✅ KUBECONFIG unset"
    ;;
  status)
    echo "Current context: $(kubectl config current-context 2>/dev/null || echo 'none')"
    echo "KUBECONFIG: ${KUBECONFIG:-~/.kube/config (default)}"
    ;;
  *)
    echo ""
    echo "Usage: k8 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  k8 eks <cluster-name> [region]     Switch to EKS cluster"
    echo "  k8 minikube                         Switch to local Minikube"
    echo "  k8 linode <kubeconfig-file>         Switch to Linode/LKE cluster"
    echo "  k8 do <kubeconfig-file>             Switch to DigitalOcean cluster"
    echo "  k8 unset                            Clear KUBECONFIG"
    echo "  k8 status                           Show current cluster"
    echo ""
    echo "Examples:"
    echo "  k8 eks demo-cluster"
    echo "  k8 eks demo-cluster eu-central-1"
    echo "  k8 linode ~/Downloads/lke-kubeconfig.yaml"
    echo "  k8 do ~/Downloads/do-kubeconfig.yaml"
    echo ""
    ;;
esac
