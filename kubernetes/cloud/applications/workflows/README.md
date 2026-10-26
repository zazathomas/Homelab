# Argo Workflows and Events

Argo Workflows and Argo Events run in the `argo` namespace. This directory includes the workflow server, EventBus, permissions, an ExternalSecret, and the `workflows-db` CloudNativePG cluster. The UI route uses `workflows.z3cyber.tech`.

## Install

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/workflows \
  | kubectl --context "$K" apply --server-side -f -
```

## Verify

```bash
kubectl --context "$K" -n argo get pods
kubectl --context "$K" -n argo get eventbus,externalsecret,httproute
kubectl --context "$K" -n databases get cluster workflows-db
```

## Files

- `workflows-values.yml` — Argo Workflows Helm values.
- `events-values.yml` — Argo Events Helm values.
- `eventbus.yml` — EventBus configuration.
- `permissions/` — workflow RBAC resources.
- `workflows-external-secret.yml` — OCI Vault-backed credentials.
- `workflows-db.yml` — CloudNativePG cluster in `databases`.
- `workflows-route.yml` — UI HTTPRoute.

## Upgrade

1. Review Argo Workflows and Argo Events compatibility notes.
2. Confirm `workflows-db` is healthy and take a CNPG plugin backup before changing database-related settings.
3. Update the chart pins in `kustomization.yml` and render/apply the directory.
4. Wait for the workflow server, controller, EventBus, and database to be healthy.
5. Test the UI, submit a small workflow, and confirm EventBus delivery.
