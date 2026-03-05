#!/bin/bash
set -e
HPA_ENABLED="${HPA_ENABLED:-false}"
NAMESPACE=book-info
GREEN='\e[32m'
RESET='\e[0m'

# deploy book-info app with or without HPA based on the flag
if [ "$HPA_ENABLED" = true ]; then
  echo -e "${GREEN}Deploying book-info with HPA enabled${RESET}"
  kubectl apply -n "$NAMESPACE" -f ./bookinfo-app
else
  echo -e "${GREEN}Creating namespace $NAMESPACE${RESET}"
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
  echo -e "${GREEN}Deploying book-info without HPA${RESET}"
  # this yaml file doesn't define resource requests/limits so HPA won't work
  kubectl apply -n "$NAMESPACE" -f https://raw.githubusercontent.com/istio/istio/release-1.29/samples/bookinfo/platform/kube/bookinfo.yaml
fi

# deploy gateway api resources
echo -e "${GREEN}Creating Gateway API resources${RESET}"
kubectl apply -f ./gateway-api
