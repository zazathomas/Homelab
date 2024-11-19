helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId="changeme" \ 
  --set-string oauth.clientSecret="changeme" \
  --wait

  guides: https://tailscale.com/kb/1438/kubernetes-operator-cluster-egress
