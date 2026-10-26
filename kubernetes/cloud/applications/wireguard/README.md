# wg-easy

wg-easy runs as a single StatefulSet in `wg-easy`. The web UI is exposed at `wg-cloud.z3cyber.tech`; WireGuard UDP traffic uses port `51820` through the `nlb-envoy-gw` Gateway. IPv6 is disabled with `DISABLE_IPV6=true`.

## Install and verify

```bash
export K=zaza-oke-cluster
kubectl --context "$K" apply --server-side -k kubernetes/cloud/applications/wireguard
kubectl --context "$K" -n wg-easy rollout status statefulset/wg-easy
kubectl --context "$K" -n wg-easy get service,httproute,udproute
```

Test a client handshake before changing the image.

## Upgrade

1. Back up or export the client configuration from the `config-wg-easy-0` PVC.
2. Update the image tag in `statefulset.yml`.
3. Apply the directory and wait for the StatefulSet rollout.
4. Confirm `DISABLE_IPV6=true` remains set.
5. Test the web UI and a WireGuard client handshake.

Keep the UDP route and service port `51820` unchanged unless all clients are reconfigured.
