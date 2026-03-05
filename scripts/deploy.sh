#!/bin/bash
set -e
HPA_ENABLED="${HPA_ENABLED:-false}"
NAMESPACE=book-info

# create namespace
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# deploy book-info app with or without HPA based on the flag
if [ "$HPA_ENABLED" = true ]; then
  echo "Deploying book-info with HPA enabled"
  kubectl apply -n "$NAMESPACE" -f ./bookinfo-app
  kubectl apply -n "$NAMESPACE" -f ./configs
else
  echo "Deploying book-info without HPA"
  # this yaml file doesn't define resource requests/limits so HPA won't work
  kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/istio/istio/release-1.29/samples/bookinfo/platform/kube/bookinfo.yaml
fi

# deploy gateway api resources
kubectl apply -f ./gateway-api
