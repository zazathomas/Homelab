helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets external-secrets/external-secrets \                                           
  --namespace external-secrets \
  --create-namespace \
  --version 0.18.0

k apply -f /Users/zaza/Desktop/Projects/Homelab/K8s/homelab/applications/external-secrets/oracle-secret.yaml

k apply -f /Users/zaza/Desktop/Projects/Homelab/K8s/homelab/applications/external-secrets/vault-secretstore.yaml

k apply -f /Users/zaza/Desktop/Projects/Homelab/K8s/homelab/applications/external-secrets/example.yaml