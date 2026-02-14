# **Talos Cluster Deployment Guide**  

This document provides step-by-step instructions for deploying a Talos-based Kubernetes cluster, including configuration generation, application, and cluster management.  

---

## **1. Generate Required Secrets**  

Talos requires a set of secrets to initialize the cluster securely. Generate the necessary secrets using:  

```bash
talosctl gen secrets
```

This will produce a `secrets.yaml` file, which will be used during configuration.  

---

## **2. Generate Cluster Configuration with Custom Patches**  

Generate the Talos cluster configuration, applying necessary patches for networking, workload management, and system configurations:  

```bash
talosctl gen config homelab-cluster https://{CONTROL_PLANE_IP}:6443 \
  --config-patch @patches/allow-cp-workloads.yaml \
  --config-patch @patches/allow-cp-lb.yaml \
  --config-patch @patches/disable-kubeproxy.yaml \
  --config-patch @patches/cni.yaml \
  --config-patch @patches/dhcp.yaml \
  --config-patch @patches/install-disk.yaml \
  --config-patch @patches/interface-names.yaml \
  --config-patch @patches/kubelet-certs.yaml \
  --config-patch-control-plane @patches/vip.yaml \
  --output homelab-cluster/ --install-image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.3
```

This step ensures that all required patches are incorporated into the cluster configuration before deployment.  

---

## **3. Apply Configuration to Nodes**  

### **Apply Configuration to Control Plane Nodes**  

Each control plane node must receive its designated configuration:  

```bash
talosctl apply -f rendered/controlplane.yaml -n $CONTROL_PLANE_IP --insecure
```

### **Apply Configuration to Worker Nodes**  

Similarly, apply the configuration to each worker node:  

```bash
talosctl apply -f rendered/worker.yaml -n $WORKER_IP --insecure
```

---

## **4. Configure Talosctl for Cluster Management**  

### **Set the Talosctl Configuration File**  

Point `talosctl` to use the generated Talos configuration:  

```bash
export TALOSCONFIG=./rendered/talosconfig
```

### **Verify Endpoint Configuration**  

Check the currently configured endpoints:  

```bash
talosctl config contexts
```

Update the configuration to include all control plane nodes:  

```bash
talosctl config endpoint cp-node-ip-1 cp-node-ip-2 cp-node-ip-3
```

---

## **5. Monitor Cluster Status**  

### **Access the Talos Dashboard**  

To inspect the cluster status, use the built-in Talos dashboard:  

```bash
talosctl dashboard -n <any-control-plane-node-ip>
```

### **Retrieve Cluster Member Information**  

Check the status of cluster members:  

```bash
talosctl get members -n <any-control-plane-node-ip>
```

---

## **6. Bootstrap the etcd Cluster**  

Once the control plane nodes are configured, initialize the etcd cluster:  

```bash
talosctl bootstrap -n <any-control-plane-node-ip>
```

This step is critical for setting up the Kubernetes control plane's distributed key-value store.  

---

## **7. Retrieve and Configure Kubeconfig**  

After the etcd cluster is bootstrapped, retrieve the Kubernetes configuration file for administrative access:  

```bash
talosctl kubeconfig -n <any-control-plane-node-ip> ./rendered/kubeconfig
export KUBECONFIG=./rendered/kubeconfig
```

This allows `kubectl` to interact with the newly deployed Kubernetes cluster.  

---

## **Conclusion**  

By following this guide, you have successfully:  
✅ Generated required secrets and configurations  
✅ Applied configuration to control plane and worker nodes  
✅ Configured `talosctl` for cluster management  
✅ Bootstrapped the etcd cluster  
✅ Retrieved the kubeconfig for Kubernetes administration  

Your Talos-based Kubernetes cluster is now operational and ready for further configuration and workload deployment. 🚀  