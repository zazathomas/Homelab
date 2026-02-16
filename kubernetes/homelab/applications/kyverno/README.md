## Steps to Install Kyverno via Helm:

1. Add the Longhorn Helm Repository:

`helm repo add kyverno https://kyverno.github.io/kyverno`

2. Update the Helm Repositories:
   
   `helm repo update`

3. Deploy Kyverno Using Helm: Install or upgrade Longhorn by specifying the desired version and custom values file:
    ```
    helm upgrade --install kyverno kyverno/kyverno \
    --namespace kyverno \
    --create-namespace \
    -f values.yaml
    ```