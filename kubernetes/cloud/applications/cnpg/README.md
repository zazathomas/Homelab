# CloudNativePG

CloudNativePG runs in `cnpg-system`. The Barman Cloud plugin is installed with the application, and database clusters run in the shared `databases` namespace.

## Current pins

- CloudNativePG chart: `0.29.1`
- Barman Cloud plugin manifest: `v0.15.1`

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/cnpg \
  | kubectl --context "$K" apply --server-side -f -
```

The kustomization installs the `databases` namespace, the R2 credential ExternalSecret, the Barman Cloud plugin, and two shared ObjectStores:

- `r2-store-backups` → `s3://pg-backups-oci/`
- `r2-store-restores` → `s3://pg-restores-oci/`

Both ObjectStores use a seven-day retention policy and the `r2-creds` Secret in `databases`.

## Verify

```bash
kubectl --context "$K" -n cnpg-system rollout status deploy/cnpg-cloudnative-pg
kubectl --context "$K" -n databases get objectstore
kubectl --context "$K" -n databases get cluster,scheduledbackup,backup
```

Application clusters must be created in `databases` and must use a stable, unique Barman `serverName`. Source clusters write WAL and physical backups to `r2-store-backups`; recovery clusters read from that ObjectStore and should write their own WAL to `r2-store-restores` with a different server name.

## Backup and recovery

See [`database-backup-recovery.md`](database-backup-recovery.md) for the tested seven-day retention, daily `02:15 UTC` schedule, fresh-backup verification, and temporary-cluster restore procedure.

`backup-example.yaml` and `restore-example.yaml` are generic examples and are not included in the kustomization. Review their ObjectStore and server-name values before using them; production clusters should follow the shared-store layout documented above.

## Upgrade

1. Confirm all database clusters are healthy and verify a recent completed backup.
2. Review CloudNativePG and Barman Cloud compatibility notes.
3. Update the chart or plugin pin in `kustomization.yaml`.
4. Render and apply this directory.
5. Confirm the operator, plugin, clusters, and ObjectStores are healthy.

Do not delete database PVCs during an operator upgrade. PostgreSQL image upgrades are separate changes and require their own backup and recovery plan.
