## Steps to Install Longhorn via Helm:

1. Add the Longhorn Helm Repository:

`helm repo add longhorn https://charts.longhorn.io`

2. Update the Helm Repositories:
   
   `helm repo update`

3. Label the Nodes for Longhorn: Ensure that each node intended to run Longhorn has the appropriate label:
   
   `kubectl label nodes node-name longhorn=true`

4. Deploy Longhorn Using Helm: Install or upgrade Longhorn by specifying the desired version and custom values file:
    ```
    helm upgrade --install longhorn longhorn/longhorn \
    --namespace longhorn-system \
    --create-namespace \
    --version 1.7.1 \
    -f values.yaml
    ```

