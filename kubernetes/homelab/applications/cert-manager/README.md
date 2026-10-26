# cert-manager

This directory installs cert-manager in `cert-manager` for the homelab cluster. It creates the Cloudflare DNS-01 issuers and the `z3cyber.tech` staging and production certificates used by the homelab Envoy Gateway.

## Current configuration

- Helm chart: `1.21.1`
- Certificate issuer: `letsencrypt-production`
- Cloudflare credential: `cloudflare-token-secret`, supplied by the `oci-vault-secretstore` ClusterSecretStore
- Production certificate: `z3cyber-tech-cert-tls`

The Cloudflare token is referenced by key `cloudflare-token`; no token value belongs in this repository.

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/homelab/applications/cert-manager \
  | kubectl --context "$K" apply --server-side -f -
```

## Verify

```bash
kubectl --context "$K" -n cert-manager rollout status deploy/cert-manager
kubectl --context "$K" -n cert-manager rollout status deploy/cert-manager-webhook
kubectl --context "$K" get clusterissuer,certificate -A
```

To refresh the source token after changing OCI Vault:

```bash
kubectl --context "$K" -n cert-manager annotate externalsecret cloudflare-token-secret \
  force-sync="$(date +%s)" --overwrite
```

## Files

- `cloudflare-token.yaml` — ExternalSecret for the Cloudflare API token.
- `cloudflare-issuer.yaml` — staging and production ClusterIssuers.
- `certificates/` — certificate resources.
- `kustomization.yaml` — chart and resource list.
