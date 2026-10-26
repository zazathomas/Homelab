# NFS CSI storage

This directory installs the Kubernetes NFS CSI driver and the `nfs-csi` StorageClass in the cloud cluster.

## Current configuration

- CSI driver chart: `4.13.6`
- Provisioner: `nfs.csi.k8s.io`
- NFS server: `10.0.10.254`
- NFS share: `/mnt/nfs_share`
- Reclaim policy: `Retain`
- Volume binding: `Immediate`
- Expansion: enabled

The StorageClass is defined in `storageClass.yaml`. Existing volumes are not recreated by a driver upgrade.

## Install and verify

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/storage \
  | kubectl --context "$K" apply --server-side -f -
kubectl --context "$K" -n kube-system rollout status deploy/csi-nfs-controller
kubectl --context "$K" -n kube-system rollout status ds/csi-nfs-node
kubectl --context "$K" get csidriver nfs.csi.k8s.io storageclass nfs-csi
```

Keep the NFS server reachable while the node DaemonSet rolls through the cluster. Test a temporary PVC before relying on a new storage configuration.
