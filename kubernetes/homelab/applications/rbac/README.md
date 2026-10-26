# Kubernetes RBAC and OIDC

The manifests in this directory bind Keycloak OIDC groups to Kubernetes roles. They do not configure the Kubernetes API server or create the Keycloak client; those are cluster and identity-provider configuration.

## Current bindings

| Group | Binding | Scope |
|---|---|---|
| `k8s-admins` | `cluster-admin` | Cluster-wide |
| `k8s-operators` | `operator-role` | Cluster-wide, excluding Secrets and Namespaces |
| `k8s-learners` | built-in `admin` | Namespace `work-experience` |
| `k8s-readeronly` | built-in `view` | Namespace `default` |

Review the manifests before changing permissions. The operator role intentionally excludes `secrets` and `namespaces`.

## Apply

```bash
export K=zaza-oke-cluster
kubectl --context "$K" apply --server-side -k kubernetes/homelab/applications/rbac
```

Verify the bindings:

```bash
kubectl --context "$K" get clusterrole operator-role
kubectl --context "$K" get clusterrolebinding oidc-admins-binding oidc-operators-binding
kubectl --context "$K" -n work-experience get rolebinding oidc-learners-binding
kubectl --context "$K" -n default get rolebinding oidc-viewers-binding
```

## OIDC client requirements

The Keycloak realm is `homelab` and the issuer is:

```text
https://sso.z3cyber.tech/realms/homelab
```

The Kubernetes API must be configured to accept the `groups` claim and the `kubernetes` audience. Configure the Keycloak client and API-server OIDC flags outside this directory, then use an `oidc-login` exec plugin in the local kubeconfig.

Example client installation on macOS:

```bash
brew install int128/kubelogin/kubelogin
```

Use the plugin's current documentation to configure the kubeconfig; do not commit a kubeconfig or token.
