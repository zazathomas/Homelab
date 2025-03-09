  
---

# **Hybrid K8s Homelab**  

This guide outlines the process for deploying Kamaji, setting up worker nodes on Proxmox, and configuring a hybrid k8s cluster.  

---

## **1. Deploying Kamaji**  

### **Prerequisites**  
Before proceeding, ensure the following:  
- You have a functional Kubernetes cluster with a Storage class.
- Helm is installed on your system.  
- kubeadm is installed on your system.
- kubectl is installed on your system.

### **Step 1: Install Cert-Manager** (Required Dependency)  

Cert-Manager is a prerequisite for Kamaji. Add the Jetstack Helm repository and install Cert-Manager:  

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```

### **Step 2: Install Kamaji**  

#### **Add the Clastix Helm Repository**  

```bash
helm repo add clastix https://clastix.github.io/charts
```

#### **Deploy Kamaji**  

```bash
kubectl replace -f https://raw.githubusercontent.com/clastix/kamaji/refs/tags/edge-24.12.1/charts/kamaji/crds/kamaji.clastix.io_tenantcontrolplanes.yaml
helm upgrade --install --namespace kamaji-system --create-namespace kamaji clastix/kamaji
```

#### **Verify Installation**  

```bash
helm status kamaji -n kamaji-system
```

Once all resources are available, update the deployment to use the latest edge image and remove the `command` field from the deployment configuration.  

---

## **2. Deploy a Sample Workload Control Plane**  

Apply the control plane template:  

```bash
kubectl apply -f tcp-template.yaml
```

### **Retrieve the Kubeconfig for the Workload Cluster**  

```bash
export TENANT_NAMESPACE=<specify namespace control plane is deployed>
export TENANT_NAME=<specify control plane name>
kubectl get secrets -n ${TENANT_NAMESPACE} ${TENANT_NAME}-admin-kubeconfig -o json \
  | jq -r '.data["admin.conf"]' \
  | base64 --decode \
  > ${TENANT_NAMESPACE}-${TENANT_NAME}.kubeconfig
```

---

## **3. Setting Up Worker Nodes on Proxmox**  
 
For bootstraping the worker nodes, I modified this [yaki](https://github.com/clastix/yaki/tree/master). Use Ubuntu 22.04/24.04 and execute the following. 

```bash
sudo apt install conntrack socat -y
curl -sfL https://raw.githubusercontent.com/zazathomas/Homelab/refs/heads/main/K8s/kamaji/yaki.sh > yaki.sh && chmod +x yaki.sh
sudo KUBERNETES_VERSION=v1.31.4 ./yaki.sh bootstrap  # Ensure Kubernetes version matches the control plane
rm yaki.sh
```

Convert the configured machine into a template and deploy three worker VMs from it.  

---

## **4. Joining Worker Nodes to the Cluster**  

### **Retrieve the Join Command**  

```bash
JOIN_CMD=$(echo "sudo ")$(kubeadm --kubeconfig=${TENANT_NAMESPACE}-${TENANT_NAME}.kubeconfig token create --print-join-command)
```

### **Add Worker Nodes to the Cluster**  

```bash
WORKER0=<worker-node-1-ip>
WORKER1=<worker-node-2-ip>
WORKER2=<worker-node-3-ip>

HOSTS=(${WORKER0} ${WORKER1} ${WORKER2})
for i in "${!HOSTS[@]}"; do
  HOST=${HOSTS[$i]}
  ssh ${USER}@${HOST} -t ${JOIN_CMD}
done
```

---

## **5. Installing Core Components on the Workload Cluster**  

Once worker nodes are joined, install essential Kubernetes components:  

- **Container Network Interface (CNI)**
- **Storage Configuration**
- **Metrics Server**

These components ensure proper networking, persistent storage, and resource monitoring in the cluster.  

---

### **Conclusion**  
By following this guide, you have successfully deployed Kamaji, set up worker nodes on Proxmox, and configured a functional hybrid kubernetes cluster. Ensure that all components are running correctly before deploying workloads.  
