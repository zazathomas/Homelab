# RustFS

RustFS provides S3-compatible object storage in the `rustfs` namespace. This deployment uses standalone mode, the `nfs-csi` StorageClass, PVCs named `rustfs-data` and `rustfs-logs`, and credentials from OCI Vault through an ExternalSecret. The S3 API is available at `api-s3.z3cyber.tech`; the console is at `s3.z3cyber.tech`.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/rustfs \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the deployment and storage:

```bash
kubectl --context "$K" -n rustfs rollout status deploy/rustfs
kubectl --context "$K" -n rustfs get pvc,externalsecret
kubectl --context "$K" -n rustfs exec deploy/rustfs -- wget -qSO- -O /dev/null http://127.0.0.1:9000/health/ready
```

## Upgrade

1. Check the RustFS release notes and update the chart version in `kustomization.yaml`.
2. Back up or verify the data on `rustfs-data`. Keep the PVC names and standalone mode unchanged.
3. Render and apply the directory with the install command above.
4. Wait for the deployment to roll out and confirm `/health/ready` returns HTTP 200.
5. Test authenticated S3 access and list an existing bucket.

Do not delete the PVCs during an application upgrade. Commit and push the version change so Argo CD and the cluster use the same manifest.
