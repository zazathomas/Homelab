# External Secrets Operator

This directory installs External Secrets Operator in `external-secrets` for the homelab cluster. The application creates the namespace and ServiceMonitor; the `oci-vault-secretstore` ClusterSecretStore and its OCI authentication resources are managed separately.

## Current configuration

- Helm chart: `2.10.0`
- Controller replicas: `1`
- Metrics and webhook metrics are enabled.

Do not add source credentials or decoded secret values to this directory.

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/homelab/applications/external-secrets \
  | kubectl --context "$K" apply --server-side -f -
```

The ClusterSecretStore must be ready before applying application ExternalSecrets:

```bash
kubectl --context "$K" get clustersecretstore oci-vault-secretstore
kubectl --context "$K" -n external-secrets rollout status deploy/external-secrets
kubectl --context "$K" get externalsecret -A
```

## Upgrade

1. Check the External Secrets Operator compatibility matrix.
2. Update the chart pin in `kustomization.yaml`.
3. Render and apply the directory.
4. Confirm the controller and webhook are ready.
5. Check representative ExternalSecrets and verify `Ready=True`.

When rotating a source value, update OCI Vault first and then force-refresh the affected ExternalSecret with its `force-sync` annotation.
