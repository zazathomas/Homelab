helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
create admin-username and password for grafana
edit the values.yaml file
helm upgrade --install -n monitoring prometheus prometheus-community/kube-prometheus-stack -f values.yaml
apply ingress to expose service
add ssl cert to ns