# Dragonfly

This directory installs the Dragonfly operator and a shared Redis-compatible `Dragonfly` resource in `dragonfly-operator-system`.

Terrapod has a separate, application-owned Dragonfly resource in `kubernetes/cloud/applications/terrapod/terrapod-dragonfly.yaml`; the shared resource documented here is not the Terrapod service.

## Current configuration

- Operator manifest: Dragonfly operator `v1.7.1`
- Resource: `dragonfly-cluster`
- Namespace: `dragonfly-operator-system`
- Replicas: `2`
- Snapshot schedule: hourly (`0 * * * *`)
- Snapshot storage: `1Gi` on `nfs-csi`
- Cluster mode: enabled
- Authentication: disabled for in-cluster use

The operator creates the `dragonfly-cluster` service. Its expected endpoint is:

```text
redis://dragonfly-cluster.dragonfly-operator-system.svc.cluster.local:6379
```

## Install and verify

```bash
export K=zaza-oke-cluster
kubectl --context "$K" apply --server-side -k kubernetes/cloud/applications/dragonfly
kubectl --context "$K" -n dragonfly-operator-system get dragonfly,pods,svc,pvc
```

Do not delete the snapshot PVC during an upgrade unless the stored data is intentionally being discarded.
