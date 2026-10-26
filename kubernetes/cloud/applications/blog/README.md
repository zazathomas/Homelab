# Ghost blog

Ghost runs as a single `Deployment` in the `ghost` namespace. Content and the SQLite database are stored on the `ghost-pvc` NFS volume. Secrets come from OCI Vault through External Secrets. Public traffic uses `blog.z3cyber.tech`; the admin route is protected by the gateway OIDC policy.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/blog \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the deployment and route:

```bash
kubectl --context "$K" -n ghost rollout status deploy/ghost
kubectl --context "$K" -n ghost get externalsecret,pvc,httproute
curl -I https://blog.z3cyber.tech
```

## Upgrade

1. Back up the Ghost content volume, including `content/data/ghost.db`.
2. Change the image tag in `ghost-deployment.yaml` and review the Ghost migration notes for the target version.
3. Render and apply the directory with the install command above.
4. Wait for `deploy/ghost` to roll out and check the pod logs for database or migration errors.
5. Test the public site and the authenticated admin route.

Keep the previous image tag until the new pod and the database have been verified. Commit and push the change so Argo CD does not revert it.
