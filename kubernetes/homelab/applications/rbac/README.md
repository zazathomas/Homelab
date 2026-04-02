# Kubernetes RBAC

## 1. Configure Kubernetes RBAC
Define your access levels using the principle of least privilege. Create **Roles** (namespace-scoped) or **ClusterRoles** (cluster-wide), then map them to Keycloak groups via **RoleBindings**.

* **Define Permissions:** Create manifests for your groups (e.g., `k8s-admins`, `k8s-operators`).
* **Bind Groups:** Ensure the `subjects` in your bindings use `kind: Group` and match the group names returned by Keycloak.
* **Apply:** `kubectl apply -f rbac-config.yaml`

## 2. Configure Keycloak OIDC Client
Set up the Identity Provider (IdP) to communicate with your cluster.

1.  **Create Client:** Create a **Public** client (e.g., `kubernetes`).
2.  **Redirect URIs:** Set to `http://localhost:8000/*` (required for local `kubelogin` flow).
3.  **Web Origins:** Set to `+`.
4.  **Mappers:** * Add a **Groups** claim to the token.
    * Ensure the **Audience** (aud) claim matches the client ID.

## 3. Install Client-Side Dependencies
Install the `kubelogin` (introspected as `oidc-login`) plugin to handle the browser-based authentication flow.

```bash
brew install int128/kubelogin/kubelogin
```

## 4. Configure Kubectl Authentication
Configure your `kubeconfig` to use the `exec` authentication method. This invokes the OIDC login plugin when you run commands.

```bash
kubectl config set-credentials oidc-user \
  --exec-api-version=client.authentication.k8s.io/v1 \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg=--oidc-issuer-url=https://sso.z3cyber.tech/realms/homelab \
  --exec-arg=--oidc-client-id=kubernetes
```

---

## 5. Standard Kubeconfig Structure
Below is a sample configuration using the `oidc-user` credentials:

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: <BASE64_CA_CERT>
    server: https://192.168.0.200:6443
  name: homelab-cluster
contexts:
- context:
    cluster: homelab-cluster
    user: oidc-user
  name: oidc-homelab
current-context: oidc-homelab
users:
- name: oidc-user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      command: kubectl
      args:
      - oidc-login
      - get-token
      - --oidc-issuer-url=https://sso.z3cyber.tech/realms/homelab
      - --oidc-client-id=kubernetes
      interactiveMode: IfAvailable
```

---

## 6. Authentication Flow
To initiate the login, execute any standard cluster command:

```bash
kubectl get nodes
```

> **Note:** Your default browser will automatically open the Keycloak login page. Once authenticated, the plugin retrieves the JWT and caches it locally for subsequent requests.