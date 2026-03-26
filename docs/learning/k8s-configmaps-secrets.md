# Kubernetes ConfigMaps & Secrets

## ConfigMap

A ConfigMap decouples configuration from container images, making apps portable across environments.

### Ways to consume a ConfigMap in a pod

| Method | How |
|---|---|
| Individual env vars | `env.valueFrom.configMapKeyRef` |
| All keys as env vars | `envFrom.configMapRef` |
| Mounted as files | `volumes` + `volumeMounts` |
| k8s API calls | Read directly from within the pod using the k8s API |

### Key points
- `volumes` is pod-level (under `spec.template.spec`)
- `volumeMounts` is container-level (under `containers`)
- ConfigMap data supports two patterns: property-like keys (`environment: alpha`) and file-like keys (`config.yaml: |`)

### Example structure
```
manifests/teams/alpha/config-map.yaml   # property + file-like keys
manifests/teams/beta/config-map.yaml    # same pattern, team-specific values
```

---

## Secrets

Secrets are similar to ConfigMaps but intended for sensitive data.

### Key differences from ConfigMap
- Values must be **base64 encoded** (not plain text)
- Only sent to nodes that have pods requesting them
- Stored in **tmpfs** (in-memory) on the node, not written to disk
- Can be independently controlled via RBAC

### Common Secret types
- `Opaque` — arbitrary key-value data (most common)
- `kubernetes.io/tls` — TLS certificates
- `kubernetes.io/dockerconfigjson` — image pull credentials

### Ways to consume a Secret in a pod

| Method | How |
|---|---|
| Individual env vars | `env.valueFrom.secretKeyRef` |
| All keys as env vars | `envFrom.secretRef` |
| Mounted as files | `volumes` + `volumeMounts` (same as ConfigMap) |

### Important caveat
Secrets are **NOT encrypted by default** — they are only base64 encoded. Anyone with etcd access can decode them. Encryption at rest requires explicit configuration:
- Generic k8s: `EncryptionConfiguration`
- GKE: Application-layer Secrets Encryption via Cloud KMS (opt-in)

**Never commit real secrets to git.** For production, use a solution like External Secrets Operator + GCP Secret Manager.

---

## Networking learnings (bonus)

- **ClusterIP** services are virtual IPs that only exist in iptables rules on cluster nodes — not routable from outside the cluster, even on the same VPC
- **Pod IPs** are VPC alias IPs and are technically routable within the VPC, but GKE auto-created firewall rules block external access to nodes by default
- From a bastion, use `kubectl port-forward` to reach services for debugging
- GCP firewall rules: lower priority number = higher precedence

---

## Next steps
- Kustomize — `base` + `overlays` pattern fits the existing `manifests/teams/` structure well
- NetworkPolicy — native k8s way to control pod-to-pod traffic
- RBAC — bind Roles to the ServiceAccounts already defined
- HPA / PodDisruptionBudget
- External Secrets Operator + GCP Secret Manager for production-grade secret management
