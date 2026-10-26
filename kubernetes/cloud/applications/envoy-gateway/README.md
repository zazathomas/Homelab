# Envoy Gateway

This directory installs Envoy Gateway in `envoy-gateway-system` and creates the cloud-cluster Gateways in the `gateway` namespace.

## Current configuration

- Gateway chart: `v1.9.1`
- Controller replicas: `3`
- GatewayClass: `envoy`
- Gateways: `cf-envoy-gw` and `nlb-envoy-gw`
- Cloudflare-facing Gateway address: internal NLB, configured by OCI annotations
- TLS hostname: `*.z3cyber.tech`
- Rate limiting: Redis at `redis.envoy-gateway-system.svc.cluster.local:6379`

Routes and policies are separate resources. The application includes Cloudflare IP detection, HTTP-to-HTTPS redirects, rate limiting, and the gateway client ExternalSecret.

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/envoy-gateway \
  | kubectl --context "$K" apply --server-side -f -
```

## Verify

```bash
kubectl --context "$K" -n envoy-gateway-system rollout status deploy/envoy-gateway
kubectl --context "$K" get gatewayclass
kubectl --context "$K" -n gateway get gateway
kubectl --context "$K" get httproute,backendtlspolicy -A
```

A healthy route should report `Accepted=True` and `ResolvedRefs=True`. Check the parent Gateway namespace when troubleshooting; cloud routes attach to Gateways in `gateway`.

## Files

- `cf-envoy-gateway.yaml` and `nlb-envoy-gateway.yaml` define the Gateways.
- `cf-http-redirect.yaml` and `nlb-http-redirects.yaml` redirect HTTP to HTTPS.
- `cf-detect-ip-policy.yaml` and `cf-ratelimit-policy.yaml` apply Cloudflare-facing policy.
- `gateway-client-external-secret.yaml` supplies the OIDC client secret.
- `values.yaml` configures the Envoy Gateway chart and rate-limit Redis backend.

## Upgrade

1. Review Envoy Gateway release notes and Gateway API compatibility.
2. Update the chart pin in `kustomization.yaml` and matching image references in `values.yaml`.
3. Render and apply the directory.
4. Wait for the controller rollout and inspect Gateway conditions.
5. Test both Cloudflare and NLB-backed routes before removing any old configuration.
