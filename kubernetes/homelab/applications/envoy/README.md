# Envoy Gateway

This directory installs Envoy Gateway and the homelab Gateway API resources in `envoy-gateway-system`.

## Current configuration

- Gateway chart: `v1.9.1`
- Controller replicas: `2`
- GatewayClass: `envoy`
- Gateways: `envoy-gw` and `cf-envoy-gw`
- `envoy-gw`: internal address `192.168.20.201`
- `cf-envoy-gw`: internal address `192.168.20.210`
- HTTPS hostname: `*.z3cyber.tech`
- Rate-limit Redis: `redis.envoy-gateway-system.svc.cluster.local:6379`

The directory also contains the GeoIP database resource, Cloudflare IP detection, redirects, rate limiting, CSRF, CEL, OIDC, and proxy configuration resources.

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/homelab/applications/envoy \
  | kubectl --context "$K" apply --server-side -f -
```

## Verify

```bash
kubectl --context "$K" -n envoy-gateway-system rollout status deploy/envoy-gateway
kubectl --context "$K" get gatewayclass
kubectl --context "$K" -n envoy-gateway-system get gateway
kubectl --context "$K" get httproute,backendtlspolicy -A
```

Routes should report `Accepted=True` and `ResolvedRefs=True`. Check the route's parent namespace and listener when troubleshooting a 404 or an attachment error.

## Upgrade

1. Review Envoy Gateway and Gateway API compatibility.
2. Update the chart pin in `kustomization.yaml` and matching image references in `values.yaml`.
3. Render and apply the directory.
4. Wait for the controller rollout.
5. Test both Gateway listeners and representative HTTPRoutes.
