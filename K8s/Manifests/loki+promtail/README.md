## Instructions for loki setup 

helm repo add grafana https://grafana.github.io/helm-charts


helm repo update


k create ns monitoring


helm upgrade --install loki grafana/loki -n monitoring -f /Users/zaza/Desktop/Projects/Homelab/K8s/Manifests/loki/loki-values.yaml

helm upgrade --install promtail grafana/promtail  -n monitoring -f /Users/zaza/Desktop/Projects/Homelab/K8s/Manifests/loki/promtail-values.yaml


Add loki source to grafana i.e http://loki-gateway

