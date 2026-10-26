# Cloudflare Tunnel

`cloudflared` runs in the `cloudflared` namespace and publishes the configured `*.z3cyber.tech` routes to the Envoy Gateway service. The tunnel credentials are supplied by an ExternalSecret.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize kubernetes/cloud/applications/cloudflared \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the tunnel:

```bash
kubectl --context "$K" -n cloudflared rollout status deploy/cloudflared
kubectl --context "$K" -n cloudflared get externalsecret tunnel-credentials
kubectl --context "$K" -n cloudflared logs deploy/cloudflared --tail=100
```

## Upgrade

1. Review the Cloudflare Tunnel release notes and update the image in `deployment.yaml`.
2. Render and apply the directory with the install command above.
3. Wait for the deployment to roll out and confirm the logs show connected tunnel sessions.
4. Test one public hostname routed through the tunnel, such as `https://sso.z3cyber.tech`.

Do not replace the tunnel credential in Kubernetes by hand. Rotate it in OCI Vault and force-refresh the ExternalSecret when required.
