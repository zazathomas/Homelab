# Terrapod

Terrapod runs in `terrapod` at `https://terrapod.z3cyber.tech`. Its PostgreSQL cluster and CloudNativePG backup resources run in `databases`. The application has its own one-replica Dragonfly resource in `terrapod`. Application credentials come from OCI Vault through namespace-local `terrapod-credentials` Secrets.

The runner listener is enabled with one replica. The declarative bootstrap job creates the `default` agent pool, and the listener joins it using the OCI-backed `terrapod-listener-token` Secret.

## OCI Vault keys

The source secret `oci-terrapod-secret` must contain:

- `admin_email`
- `admin_password`
- `db_username` — `terrapod`
- `db_password`
- `webhook_secret`

The application-storage source `oci-r2-creds` must contain `ACCESS_KEY_ID` and `ACCESS_SECRET_KEY`.

The join token is stored in the same OCI object under `agent_pool_join_token`. It is exposed only through the namespace-local `terrapod-listener-token` Secret with key `join_token`.

## Agent pool

The Helm bootstrap job creates the single `default` agent pool from `terrapod-listener-token`. The listener uses that token, then persists its X.509 identity in the chart-managed `terrapod-listener-credentials` Secret. Runner Jobs are created in `terrapod`; the listener is limited to one concurrent launch by the current values file.

Do not put the join token directly in `terrapod-values.yaml` or commit the generated listener credentials.

## Webhooks

VCS webhooks and run-task callbacks use `https://terrapod.z3cyber.tech/webhooks/`. The dedicated HTTPRoute matches that prefix, strips `/webhooks/`, and sends the resulting API paths through `terrapod-web:3000`:

- `/webhooks/api/terrapod/v1/vcs-events`
- `/webhooks/api/terrapod/v1/task-stage-results`

The HMAC value is copied from `oci-terrapod-secret.webhook_secret` into the `terrapod-credentials` Secret and injected into the API for GitHub and GitLab. Configure the same value in the provider webhook settings.

## API scratch storage

The API mounts `/var/lib/terrapod/tmp` as a 5Gi node-local `emptyDir`. VCS archive downloads, drift checks, cost-price refreshes, and run planning use this disposable path. It intentionally avoids the default `nfs-csi` generic ephemeral volume, which is mounted as `nobody:nogroup` and is not writable by the API's non-root UID 1000.

## Database backups

`terrapod-db` runs in `databases` and uses the shared Barman Cloud stores:

- `r2-store-backups` → `s3://pg-backups-oci/`
- `r2-store-restores` → `s3://pg-restores-oci/`

The stable source server name is `terrapod-db`. Retention is seven days, and `terrapod-db-backup` runs daily at `02:15 UTC`. The application connects to the CNPG read-write service `terrapod-db-rw.databases.svc.cluster.local` on port `5432`, database `terrapod`.

The same Vault-backed credential data is materialized in both `terrapod` and `databases` because Secrets are namespace-scoped.

## Restore verification

`terrapod-db-restore-example.yaml` is a manual template and is not included in the kustomization. It reads the source history from `r2-store-backups` with `terrapod-db` and writes restored-cluster WAL to `r2-store-restores` with `terrapod-db-restore`.

Use a fresh physical backup for a verification drill:

1. Create a one-time `Backup` and wait for `completed`.
2. Apply the restore example and wait for `terrapod-db-restore` to become healthy.
3. Temporarily point Terrapod at the restored database and verify a representative UI role.
4. Switch the application back to `terrapod-db` and confirm the original deployment is healthy.
5. Delete the temporary cluster and test-only backup.

```bash
export K=zaza-oke-cluster
kubectl --context "$K" apply -f kubernetes/cloud/applications/terrapod/terrapod-db-restore-example.yaml
kubectl --context "$K" -n databases get cluster terrapod-db-restore -w
kubectl --context "$K" -n databases delete cluster terrapod-db-restore
```

The restored PostgreSQL roles and password hashes come from the physical backup. The application Secret must contain a password matching the restored database role.

## Files

| File | Purpose |
|---|---|
| `terrapod-values.yaml` | Helm values, database connection, storage, webhook URL, and HMAC Secret references |
| `terrapod-api-tmpdir-patch.yaml` | Writable 5Gi node-local scratch volume for the API |
| `terrapod-route.yaml` | Main UI/API HTTPRoute for `terrapod.z3cyber.tech` |
| `terrapod-webhook-route.yaml` | Main-host `/webhooks/` HTTPRoute with prefix rewrite |
| `terrapod-credentials-external-secret.yaml` | Application credentials in `terrapod` |
| `terrapod-listener-token-external-secret.yaml` | OCI-backed agent-pool join token in `terrapod` |
| `terrapod-db-credentials-external-secret.yaml` | Matching credential Secret in `databases` |
| `terrapod-db.yaml` | PostgreSQL cluster in `databases` |
| `terrapod-db-backup.yaml` | Daily ScheduledBackup |
| `terrapod-db-restore-example.yaml` | Manual restore/PITR template |
| `terrapod-dragonfly.yaml` | Application-owned Redis-compatible cache |
| `terrapod-r2-external-secret.yaml` | R2 credentials for application storage |

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/terrapod \
  | kubectl --context "$K" apply --server-side -f -
```

Verify both namespaces:

```bash
kubectl --context "$K" -n terrapod rollout status deploy/terrapod-api
kubectl --context "$K" -n terrapod rollout status deploy/terrapod-web
kubectl --context "$K" -n terrapod get httproute,externalsecret,pvc,dragonfly
kubectl --context "$K" -n databases get cluster,objectstore,scheduledbackup,backup
```
