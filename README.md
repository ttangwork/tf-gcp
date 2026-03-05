# Terraform GCP playground

This repository contains Terraform code that deploys GCP resources and the related workload deployment scripts and workflows

## GKE
A standard GKE cluster is deployed in `us-central1` with its dedicated `vpc`.

### Workload Deployment
Deploying Istio's sample book-info app using `kubectl` as well as `Helm` packaging.
