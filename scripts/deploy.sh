#!/bin/bash
set -e
DESTROY_FLAG="${DESTROY_FLAG:-false}"
GREEN='\e[32m'
RESET='\e[0m'

KYVERNO_VERSION="${KYVERNO_VERSION:-v1.13.4}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$DESTROY_FLAG" = true ]; then
  echo -e "${GREEN}Deleting team namespaces and platform resources${RESET}"
  kubectl delete -f "$SCRIPT_DIR/teams/alpha/" --ignore-not-found
  kubectl delete -f "$SCRIPT_DIR/teams/beta/" --ignore-not-found
  kubectl delete -f "$SCRIPT_DIR/platform/" --ignore-not-found
  kubectl delete -f "$SCRIPT_DIR/namespaces/" --ignore-not-found
  exit 0
fi

# install Kyverno if not already installed
if ! kubectl get namespace kyverno &>/dev/null; then
  echo -e "${GREEN}Installing Kyverno ${KYVERNO_VERSION}${RESET}"
  kubectl create -f "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml"
  echo -e "${GREEN}Waiting for Kyverno to be ready${RESET}"
  kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=kyverno -n kyverno --timeout=120s
fi

# create namespaces first
echo -e "${GREEN}Creating namespaces${RESET}"
kubectl apply -f "$SCRIPT_DIR/namespaces/"

# deploy platform resources (gateway, kyverno policies)
echo -e "${GREEN}Deploying platform resources${RESET}"
kubectl apply -f "$SCRIPT_DIR/platform/"

# deploy team resources (services, routes, policies)
echo -e "${GREEN}Deploying alpha resources${RESET}"
kubectl apply -f "$SCRIPT_DIR/teams/alpha/"

echo -e "${GREEN}Deploying beta resources${RESET}"
kubectl apply -f "$SCRIPT_DIR/teams/beta/"

echo -e "${GREEN}Deployment complete${RESET}"
