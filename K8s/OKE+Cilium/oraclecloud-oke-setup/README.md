# Oracle Kubernetes Engine (OKE) Cluster Setup with Cilium

This guide provides step-by-step instructions for setting up a new managed Oracle Kubernetes Engine (OKE) cluster using Flannel as the network overlay and transitioning to Cilium for advanced networking and security capabilities.

## Prerequisites

- Oracle Cloud Infrastructure (OCI) account with permissions to create and manage OKE clusters.
- OCI CLI installed and configured on your local machine.
- Helm installed on your local machine.
- Basic understanding of Kubernetes and OCI networking concepts.

## 1. Create a New Managed OKE Cluster

1. Log in to the Oracle Cloud Console.
2. Navigate to **Oracle Kubernetes Engine (OKE)** and select **Create Cluster**.
3. Choose **Create basic cluster** and configure the following settings:
   - **Network Overlay**: Select Flannel.
   - **Public IP Address**: Assign public IP addresses for worker nodes.
   - **Secure Subnets**: Configure secure subnets for Load Balancer services and API endpoints.
   - **Private Subnet**: Configure a private subnet for the node pool.

Once the cluster is created and the nodes are ready, proceed with the following steps to set up Cilium and configure the cluster.

## 2. Access the Cluster

To access the cluster locally, use the required OCI commands to configure your `kubeconfig`:

```oci ce cluster create-kubeconfig --cluster-id <cluster-id> --file $HOME/.kube/config --region <region> --token-version 2.0.0```

## 3. Install the Kubernetes Metrics Server
The Metrics Server provides resource usage data such as CPU and memory, which can be viewed via kubectl top commands:

```kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml```

## 4. Install and Configure Cilium

```
helm repo add cilium https://helm.cilium.io
cilium install -f values-cloud.yaml
curl -sLO https://raw.githubusercontent.com/cilium/cilium/master/contrib/k8s/k8s-unmanaged.sh
chmod +x k8s-unmanaged.sh
./k8s-unmanaged.sh
kubectl delete pod {each pod from the above}
cilium status --wait
```

## 5. Remove Flannel and Kube-Proxy DaemonSets
To ensure Cilium handles networking exclusively, remove the existing Flannel and Kube-Proxy components:

- Delete the Flannel DaemonSet: `kubectl delete -n kube-system daemonset kube-flannel-ds`
- Delete the Kube-Proxy DaemonSet: `kubectl delete -n kube-system daemonset kube-proxy`

## 6. Upgrade Cilium with Control Plane Private IP
To ensure proper communication with the control plane, follow these steps:
- Copy the control plane's private IP address from the OKE console.
- Add the private IP to the Cilium values file.
- `cilium upgrade -f /Users/zaza/Desktop/Projects/Homelab/K8s/OKE+Cilium/OCI-OKE-Setup/cilium-values-cloud.yaml -f /Users/zaza/Desktop/Projects/Homelab/K8s/OKE+Cilium/oci-oke-setup/cilium-values-monitoring.yaml --version 1.16.5 --namespace kube-system`

## 7. Test Cilium Connectivity
Run the Cilium connectivity test to ensure that Cilium is functioning correctly:
`cilium connectivity test`

## 8. Setup Storage
Setup an nfs server first.

To set up nfs storage, execute the following commands:

```bash
helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.5.0
kubectl apply -f storageclass.yaml
```

## Conclusion
By following this guide, you've successfully set up an OKE cluster with Flannel as the initial network overlay and transitioned to Cilium for enhanced networking and security. Cilium provides advanced features such as network policies, load balancing, and observability, making it a powerful choice for Kubernetes networking.

If you encounter any issues or need further assistance, please refer to the Cilium documentation or the Oracle Kubernetes Engine documentation.

Happy Kubernetes-ing!