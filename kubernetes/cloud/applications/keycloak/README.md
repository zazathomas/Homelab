# Keycloak

Keycloak runs in the `keycloak` namespace at `https://sso.z3cyber.tech`, realm `homelab`. It is a single replica backed by a two-instance CloudNativePG cluster in `databases`.

## Components

| Namespace | Resource | Notes |
|---|---|---|
| `keycloak` | StatefulSet `keycloak` | Image `ghcr.io/zazathomas/keycloak-z3cyber:26.8.1-1` |
| `keycloak` | Service `keycloak-service` | Port 80 to container port 8080 |
| `keycloak` | HTTPRoute `keycloak-route` | Attached to `gateway/cf-envoy-gw` |
| `keycloak` | ExternalSecret `keycloak-secret` | Reads OCI Vault key `oci-keycloak-secret` |
| `databases` | Cluster `keycloak-db` | Two instances on `nfs-csi` |
| `databases` | ScheduledBackup `keycloak-db-backup` | Daily at 02:15 UTC, seven-day retention |

TLS is terminated by the Gateway using `z3cyber-tech-cert-tls`. The HTTP-to-HTTPS redirect is defined in `kubernetes/cloud/applications/envoy-gateway/cf-http-redirect.yaml`.

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize kubernetes/cloud/applications/keycloak \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the application and database:

```bash
kubectl --context "$K" -n keycloak rollout status sts/keycloak --timeout=10m
kubectl --context "$K" -n databases get cluster keycloak-db
kubectl --context "$K" get httproute keycloak-route -n keycloak
curl -s -o /dev/null -w "%{http_code}\n" \
  https://sso.z3cyber.tech/realms/homelab/.well-known/openid-configuration
```

## Configuration

The StatefulSet uses the `keycloak-secret` keys `admin_user`, `admin_password`, `db_username`, and `db_password`. The database URL is:

```text
jdbc:postgresql://keycloak-db-rw.databases.svc:5432/keycloak
```

`KC_HOSTNAME` must remain `https://sso.z3cyber.tech`; it must match the route hostname and the issuer advertised by the realm.

## Database recovery

`keycloak-db-restore-example.yaml` is a manual template and is not included in the kustomization. It reads source history from `r2-store-backups` with `keycloak-db`, and writes restore-cluster WAL to `r2-store-restores` with `keycloak-db-restore`.

```bash
export K=zaza-oke-cluster
kubectl --context "$K" apply -f kubernetes/cloud/applications/keycloak/keycloak-db-restore-example.yaml
kubectl --context "$K" -n databases get cluster keycloak-db-restore -w
kubectl --context "$K" -n databases delete cluster keycloak-db-restore
```

Verify the restored database before switching production traffic. The restored PostgreSQL roles and password hashes come from the backup, so the application Secret must contain matching credentials.

## Upgrade

1. Take a logical dump and verify a completed CNPG backup.
2. Update the image in `keycloak-sts.yaml`.
3. Apply the directory and wait for the StatefulSet rollout.
4. Watch the Keycloak logs for migration completion.
5. Verify the OIDC discovery endpoint and one dependent client.

Keycloak schema migrations are forward-only. Do not start an older image against a database that has already been migrated; restore the database into an empty cluster first.
