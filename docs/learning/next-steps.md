# GKE Learning Roadmap — Next Steps

Based on what's already built in this repo (multi-tenant GKE platform with Gateway API, Kyverno, network policies, Helm charts, and Terraform CI/CD).

## Near-term (builds directly on what you have)

### 1. Deploy a real application

Replace the nginx placeholders with an actual app (e.g., a simple Go or Python API). This forces you to learn container image builds, Artifact Registry, and real health check tuning.

### 2. CI/CD for workloads

Your Terraform CI exists, but there's no pipeline for deploying app changes to the cluster. Add a GitHub Actions workflow that builds a container image, pushes to Artifact Registry, and updates the deployment (via `kubectl set image` or Helm upgrade through the Bastion/Workload Identity).

### 3. Secrets management with Secret Manager

You're using plain Kubernetes Secrets (base64, not encrypted). Integrate GCP Secret Manager with the [Secret Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/) so secrets are synced from GCP into pods. This is a common production pattern.

### 4. TLS / HTTPS

Your Gateway listens on HTTP port 8080. Add a TLS listener with a Google-managed certificate. This covers Certificate resources and HTTPS routing — essential for real workloads.

### 5. Custom domain with Cloud DNS

Wire up a real domain (or a free subdomain) so `alpha.yourdomain.com` actually resolves to the load balancer IP instead of using `-H Host:` headers.

## Medium-term (deeper GKE concepts)

### 6. Horizontal Pod Autoscaler (HPA)

Add CPU/memory-based autoscaling to your deployments. Pairs well with your existing resource requests/limits and node autoscaler (1-3 nodes).

### 7. Observability stack

You have Managed Prometheus enabled but no dashboards or alerts. Create a GCP Monitoring dashboard, set up alerting policies (e.g., pod crash loops, high latency), and explore PromQL queries.

### 8. Ingress/egress hardening

Your egress network policy currently allows all outbound (`0.0.0.0/0`). Tighten it to only allow specific destinations (e.g., only GCP APIs). This teaches you about real zero-trust networking.

### 9. Workload Identity in practice

You've enabled it at the cluster level but no pod actually uses it yet. Create a workload that needs to talk to a GCP service (e.g., read from a GCS bucket or Pub/Sub) using a Kubernetes ServiceAccount mapped to a GCP SA.

### 10. GitOps with ArgoCD or Flux

Instead of `make deploy`, install ArgoCD and have it sync your manifests from the repo. This is the industry-standard deployment pattern for Kubernetes.

## Longer-term (production-grade skills)

### 11. Multi-environment setup

Add a `staging` environment in Terraform with a separate cluster, and promote changes through staging to prod.

### 12. Backup and disaster recovery

Explore Velero for cluster backup, or GKE Backup for GKE.

### 13. Service mesh (Istio / Anthos Service Mesh)

Adds mTLS between pods, traffic splitting, circuit breaking. Heavy but very valuable to understand.

### 14. Binary Authorization

You've enabled the API but aren't using it. Enforce that only signed images from your Artifact Registry can run in the cluster.
