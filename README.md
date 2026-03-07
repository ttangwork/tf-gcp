# Terraform GCP playground

This repository contains Terraform code that deploys GCP resources and the related workload deployment scripts and workflows

## Infrastructure Provision
The infrastructure can be deployed by `Terraform GCP` workflow in Github Actions.

## GKE
A standard GKE cluster is deployed in `us-central1` with its dedicated `vpc`.

### Workload Deployment
Deploying Istio's sample book-info app using `kubectl` as well as `Helm` packaging.

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

There are 2 ways to deploy workloads to GKE: `kubectl` or `helm`.

#### kubectl

First you need to login:

```
gcloud auth application-default login
```

To connect to Bastion VM via IAP tunnel:

```
gcloud compute ssh YOUR_CLUSTER_NAME --tunnel-through-iap --zone=YOUR_ZONE --project=YOUR_PROJECT_ID
```

Once connected, you can then clone the repo and run [deploy.sh](./scripts/deploy.sh)

#### helm

Validate the template:

```
helm template book-info ./helm/book-info
```

Linting:

```
helm lint ./helm/book-info
```

Install the package:

```
helm install
```

To upgrade the package:

```
helm upgrade
```

To uninstall:

```
helm uninstall
```
