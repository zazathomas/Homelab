# PostgreSQL backup and recovery with CloudNativePG

This guide describes the backup and restore layout used by the cloud cluster. It uses CloudNativePG with the Barman Cloud plugin and two shared S3-compatible ObjectStores in the `databases` namespace.

## Storage layout

| ObjectStore | Bucket | Purpose |
|---|---|---|
| `r2-store-backups` | `s3://pg-backups-oci/` | Source WAL archives and physical backups |
| `r2-store-restores` | `s3://pg-restores-oci/` | WAL written by restored clusters |

Both stores use the R2 endpoint and the namespace-local `r2-creds` Secret. Retention is seven days. Barman separates histories by `serverName`, so every source or restore cluster needs a stable, unique value.

The ObjectStores are defined in:

- `objectstore-backups.yaml`
- `objectstore-restores.yaml`

They are installed by `kubernetes/cloud/applications/cnpg/kustomization.yaml`.

## Source cluster configuration

A production cluster in `databases` archives WAL to the backup store:

```yaml
spec:
  plugins:
    - name: barman-cloud.cloudnative-pg.io
      enabled: true
      isWALArchiver: true
      parameters:
        barmanObjectName: r2-store-backups
        serverName: app-db
```

Use the same `serverName` in the cluster plugin, scheduled backups, and recovery source. Do not reuse a source server name for a temporary restored cluster.

## Scheduled physical backups

The standard schedule is daily at 02:15 UTC. CloudNativePG schedules use six fields: seconds, minutes, hours, day of month, month, and day of week.

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: app-db-backup
  namespace: databases
spec:
  schedule: "0 15 2 * * *"
  backupOwnerReference: self
  cluster:
    name: app-db
  method: plugin
  pluginConfiguration:
    name: barman-cloud.cloudnative-pg.io
    parameters:
      barmanObjectName: r2-store-backups
      serverName: app-db
```

WAL archiving runs continuously. A base backup limits the amount of WAL needed during recovery and provides the physical restore point.

Create a one-time backup before an upgrade or restore drill:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: app-db-before-change
  namespace: databases
spec:
  cluster:
    name: app-db
  method: plugin
  pluginConfiguration:
    name: barman-cloud.cloudnative-pg.io
    parameters:
      barmanObjectName: r2-store-backups
      serverName: app-db
```

Wait for `status.phase: completed` before proceeding.

## Restore into a temporary cluster

Recovery creates a new cluster. It does not restore data into an existing cluster in place.

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: app-db-restore
  namespace: databases
spec:
  instances: 1
  bootstrap:
    recovery:
      source: app-db-backups

  plugins:
    - name: barman-cloud.cloudnative-pg.io
      enabled: true
      isWALArchiver: true
      parameters:
        barmanObjectName: r2-store-restores
        serverName: app-db-restore

  externalClusters:
    - name: app-db-backups
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: r2-store-backups
          serverName: app-db

  storage:
    storageClass: nfs-csi
    size: 1Gi
```

The restore cluster reads the source history from `r2-store-backups` and writes its own WAL to `r2-store-restores`. Do not include `bootstrap.initdb` in a recovery cluster.

For point-in-time recovery, add a target inside the retained seven-day WAL window:

```yaml
bootstrap:
  recovery:
    source: app-db-backups
    recoveryTarget:
      targetTime: "2026-10-25T06:00:00Z"
```

## Tested application verification procedure

Use this process when verifying an application restore, such as Terrapod:

1. Create a fresh physical `Backup` from the source cluster.
2. Wait for the backup to reach `completed`.
3. Create a temporary recovery cluster with a new `serverName`.
4. Wait for the recovery cluster to become healthy.
5. Confirm the expected database, tables, and roles exist.
6. Temporarily point the application at the restored cluster and verify the UI or a representative login.
7. Restore the original application connection and confirm it is healthy.
8. Delete the temporary cluster and any test-only backup resources.

Database roles and password hashes are part of the physical backup. The application Secret must therefore contain the password that matches the restored database role; recovery does not merge a new Kubernetes Secret into PostgreSQL.

## Verification commands

```bash
export K=zaza-oke-cluster
kubectl --context "$K" -n cnpg-system rollout status deploy/cnpg-cloudnative-pg
kubectl --context "$K" -n databases get objectstore,cluster,scheduledbackup,backup
kubectl --context "$K" -n databases describe scheduledbackup app-db-backup
kubectl --context "$K" -n databases get backup app-db-before-change -o jsonpath='{.status.phase}{"\n"}'
```

Remove temporary recovery resources only after verification:

```bash
kubectl --context "$K" -n databases delete cluster app-db-restore
```

Keep periodic logical dumps outside the physical backup chain for portability and migrations. Protect both buckets with least-privilege credentials and alert on failed WAL archiving or failed `Backup` resources.
