# Homelab

Infrastructure and Kubernetes configuration for the homelab and cloud clusters.

## Repository layout

- `infrastructure/` — infrastructure notes and Proxmox configuration.
- `docker/` — standalone Docker Compose services, including Pi-hole.
- `kubernetes/cloud/` — cloud-cluster applications and Argo CD application discovery.
- `kubernetes/homelab/` — on-premises cluster applications and Argo CD application discovery.
- `kubernetes/kamaji/` — Kamaji workload-cluster experiments and bootstrap material.
- `kubernetes/k8s-security-testing/` — Kubernetes security-testing material.

Most Kubernetes application directories contain a `kustomization.yaml` or `kustomization.yml`. Directories that use Helm charts declare them under `helmCharts`; render those directories with `--enable-helm`.

## Deployment model

Argo CD is the GitOps controller. Application manifests are grouped by cluster under `kubernetes/cloud/applications` and `kubernetes/homelab/applications`. Secrets are supplied through External Secrets and OCI Vault; secret values must not be committed to this repository.

The cloud cluster uses Envoy Gateway and Cloudflare-backed routes for public services. PostgreSQL clusters run under CloudNativePG, with Barman Cloud backups stored in the shared object stores documented in [`kubernetes/cloud/applications/cnpg/database-backup-recovery.md`](kubernetes/cloud/applications/cnpg/database-backup-recovery.md).

## Rendering and applying an application

Set the target context first, then render the application before applying it:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/terrapod \
  | kubectl --context "$K" apply --server-side -f -
```

For a directory without Helm charts, use `kubectl apply -k` instead. Check the application README before applying changes; it records namespaces, prerequisites, and verification commands.

## Safety checks

Before committing Kubernetes changes:

```bash
git diff --check
git status --short
```

Keep credentials in OCI Vault or another secret manager. ExternalSecret manifests should reference secret keys without embedding their values. Do not commit kubeconfigs, private keys, decoded Kubernetes Secret data, or provider tokens.
