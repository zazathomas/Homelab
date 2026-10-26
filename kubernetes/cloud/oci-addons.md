There is no supported permanent OCI setting for disabling kube-proxy on Basic clusters. You can remove the current resources manually:

 ```bash
   kubectl --context zaza-oke-cluster \
     -n kube-system delete ds kube-flannel-ds kube-proxy
 ```

 Prevent Flannel from returning on existing nodes:

 ```bash
   kubectl --context zaza-oke-cluster label nodes --all \
     oci.oraclecloud.com/custom-k8s-networking=true --overwrite



Run these checks periodically:

 ```bash
   export K=zaza-oke-cluster

   kubectl --context "$K" -n kube-system get ds,pods \
     | grep -Ei 'flannel|kube-proxy' || true

   cilium status --context "$K" --wait
 ```

 Confirm the configuration:

 ```bash
   kubectl --context "$K" -n kube-system get cm cilium-config -o yaml \
     | grep -E 'cni-exclusive|kube-proxy-replacement|routing-mode|tunnel-protocol'
 ```

 Expected:

 ```text
   cni-exclusive: "true"
   kube-proxy-replacement: "true"
   routing-mode: tunnel
   tunnel-protocol: vxlan
 ```

 Confirm Cilium owns Kubernetes Services:

 ```bash
   POD=$(kubectl --context "$K" -n kube-system \
     get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')

   kubectl --context "$K" -n kube-system exec "$POD" -c cilium-agent -- \
     cilium-dbg service list | grep '10.96.0.1:443'
 ```

 It should show an active API backend.