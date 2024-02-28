#!/bin/bash

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--flannel-backend=none --no-flannel' sh -s - \
  --disable-network-policy \
  --disable "servicelb" \
  --disable "traefik" \
  --disable "metrics-server"

sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.7/install/kubernetes/quick-install.yaml



helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium \
    --namespace kube-system \
    --set hubble.enabled=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true \
    --set hubble.ui.service.type=ClusterIP \
    --set hubble.relay.service.type=ClusterIP \
    --set loadBalancer.mode=dsr \
    --set kubeProxyReplacement=strict \
    --set tunnel=disabled \
    --set autoDirectNodeRoutes=true \
    --set k8sServiceHost=192.168.0.57 \
    --set k8sServicePort=6443 \
    --set egressGateway.enabled=true \
    --set operator.replicas=1




    alias kube-vip="docker run --network host --rm ghcr.io/kube-vip/kube-vip"
    kube-vip manifest pod \
    --interface eth0 \
    --vip 192.168.0.57 \
    --controlplane \
    --services \
    --arp \
    --leaderElection > kube-vip.yaml



helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=192.168.0.127 \
  --set k8sServicePort=6443 \
  --set egressGateway.enabled=true \
  --set bpf.masquerade=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true





  --node-taints node.cilium.io/agent-not-ready=true:NoExecute