# External Secrets Operator

External Secrets Operator runs in the `external-secrets` namespace. This application installs the controller and reuses the existing `ClusterSecretStore` named `oci-vault-secretstore`; the store and its OCI credentials are managed elsewhere.

Current chart version: `2.14.0`.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/external-secrets \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the operator and store:

```bash
kubectl --context "$K" -n external-secrets rollout status deploy/external-secrets
kubectl --context "$K" get clustersecretstore oci-vault-secretstore
kubectl --context "$K" get externalsecret -A
```

## Upgrade

1. Check the External Secrets Operator compatibility matrix and release notes.
2. Update the chart version in `kustomization.yaml`; keep `values.yaml` and the existing ClusterSecretStore contract unchanged.
3. Render and apply the directory with the install command above.
4. Wait for the controller and webhook to become ready.
5. Check representative ExternalSecrets in each namespace and confirm they remain `Ready=True`.

When rotating a source secret, update OCI Vault first, then force-refresh the affected ExternalSecret with its `force-sync` annotation. Never place secret values in this directory.
