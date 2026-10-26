# cert-manager

cert-manager runs in the `cert-manager` namespace. It issues the cluster's ACME certificates through the Cloudflare DNS-01 solver. The Cloudflare token is supplied by the `cloudflare-token-external-secret.yaml` ExternalSecret.

Current chart/app version: `1.21.3`.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/cert-manager \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the controller and issuers:

```bash
kubectl --context "$K" -n cert-manager rollout status deploy/cert-manager
kubectl --context "$K" -n cert-manager rollout status deploy/cert-manager-webhook
kubectl --context "$K" get clusterissuer,certificate -A
```

## Upgrade

1. Back up the cert-manager CRDs, Issuers, Certificates, and ACME resources.
2. Review the release notes and update the chart version in `kustomization.yaml`.
3. Render and apply the directory with the install command above.
4. Confirm the controller, webhook, and cainjector are ready and the CRDs serve `v1`.
5. Check ClusterIssuer readiness and wait for any certificate renewals to complete.

To refresh the Cloudflare token after changing OCI Vault:

```bash
kubectl --context "$K" -n cert-manager annotate externalsecret cloudflare-token-secret force-sync="$(date +%s)" --overwrite
```

Keep the `oidc` and DNS credentials outside Helm values. Do not print secret data while troubleshooting.
