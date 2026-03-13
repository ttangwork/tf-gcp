# Terraform GCP playground

[![Terraform GCP](https://github.com/ttangwork/tf-gcp/actions/workflows/terraform.yml/badge.svg)](https://github.com/ttangwork/tf-gcp/actions/workflows/terraform.yml)

This repository contains infrastructure code that deploys GCP services & demo workloads

## Infrastructure Provision
The infrastructure can be deployed by `Terraform GCP` workflow in Github Actions.

## GKE
A standard GKE cluster is deployed in `us-central1` with its dedicated `vpc`. The cluster has the Gateway API enabled for managing external traffic routing.

### Architecture

The cluster uses the Kubernetes Gateway API with GKE's managed L7 external load balancer (`gke-l7-global-external-managed`). Traffic is routed using host-based routing through a shared gateway:

- **Platform namespace** - owns the shared `ext-gateway` (port 8080)
- **Team namespaces** - each team owns their own HTTPRoute, backend policy, and health check policy
- Namespaces require the `gateway-access: "true"` label to attach routes to the gateway

### Workload Deployment

Team workloads are deployed using `kubectl` via [deploy.sh](./scripts/deploy.sh).

## Local Deployment

### Infrastructure

You shouldn't deploy the infrastructure from your local machine, it's best practice to deploy them through designated workflows in Github Actions. However you can run following `terraform` commands to lint and validate Terraform files if needed.

Initialization of Terraform without remote backend:

```
terraform init -backend=false
```

To format Terraform files automatically:

```
terraform fmt -recursive .
```

To validate internal structure and logic of your Terraform code:

```
terraform validate .
```
### Workloads

You can run `kubectl` to manage workloads/resources in GKE.

First you need to login:

```
gcloud auth application-default login
```

To connect to Bastion VM via IAP tunnel:

```
gcloud compute ssh YOUR_CLUSTER_NAME --tunnel-through-iap --zone=YOUR_ZONE --project=YOUR_PROJECT_ID
```

Once connected, you can then clone the repo and run [deploy.sh](./scripts/deploy.sh):

```
bash scripts/deploy.sh
```

To destroy all deployed resources:

```
DESTROY_FLAG=true bash scripts/deploy.sh
```

#### Accessing team applications

Each team's application is accessible via host-based routing on port 8080:

```
curl -H "Host: alpha.example.com" http://<LB_IP>:8080/
curl -H "Host: beta.example.com" http://<LB_IP>:8080/
```
