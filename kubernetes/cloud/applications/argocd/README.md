# Argo CD

Argo CD runs in the `argocd` namespace and manages applications from this repository. The Helm chart is pinned in `kustomization.yml`; OIDC settings and the ExternalSecret-backed admin configuration live in `argocd-values.yml` and `argocd-external-secret.yaml`.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/argocd \
  | kubectl --context "$K" apply --server-side -f -
```

Check the rollout:

```bash
kubectl --context "$K" -n argocd get pods
kubectl --context "$K" -n argocd get application
```

## Upgrade

1. Review the chart release notes and update `kustomization.yml`.
2. Review `argocd-values.yml`, especially the Keycloak OIDC client-secret reference. Keep `configs.secret.createSecret: false` when `argocd-secret` is managed outside Helm.
3. Render and apply the directory with the install command above.
4. Wait for the server, repo server, application controller, and Redis pods to become ready.
5. Test `https://argocd.z3cyber.tech/auth/login` and an OIDC login before syncing dependent applications.

Commit and push the change, then sync the `argocd` Argo CD application so the Git state matches the cluster.
