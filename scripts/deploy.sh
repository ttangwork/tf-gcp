#!/bin/bash
set -e
DESTROY_FLAG="${DESTROY_FLAG:-false}"
GREEN='\e[32m'
RESET='\e[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$DESTROY_FLAG" = true ]; then
  echo -e "${GREEN}Deleting team namespaces and platform resources${RESET}"
  kubectl delete -f "$SCRIPT_DIR/teams/alpha/" --ignore-not-found
  kubectl delete -f "$SCRIPT_DIR/teams/beta/" --ignore-not-found
  kubectl delete -f "$SCRIPT_DIR/platform/" --ignore-not-found
  kubectl delete -f "$SCRIPT_DIR/namespaces/" --ignore-not-found
  exit 0
fi

# create namespaces first
echo -e "${GREEN}Creating namespaces${RESET}"
kubectl apply -f "$SCRIPT_DIR/namespaces/"

# deploy platform resources (gateway)
echo -e "${GREEN}Deploying platform resources${RESET}"
kubectl apply -f "$SCRIPT_DIR/platform/"

# deploy team resources (services, routes, policies)
echo -e "${GREEN}Deploying alpha resources${RESET}"
kubectl apply -f "$SCRIPT_DIR/teams/alpha/"

echo -e "${GREEN}Deploying beta resources${RESET}"
kubectl apply -f "$SCRIPT_DIR/teams/beta/"

echo -e "${GREEN}Deployment complete${RESET}"
