
# **ClusterAPI Deployment Guide**  

This guide provides a structured approach to deploying **ClusterAPI** on **Proxmox**, including setting up the **Image Builder**, configuring ClusterAPI, and initializing the cluster.  

---

## **1. Image Builder Deployment**  

### **Step 1: Clone the Image Builder Repository**  

Begin by cloning the **Image Builder** repository:  

```bash
git clone git@github.com:kubernetes-sigs/image-builder.git
```

### **Step 2: Install Dependencies**  

Navigate to the `capi` directory and install the required dependencies:  

```bash
cd image-builder/images/capi
make deps
export PATH=$PWD/.bin:$PATH
```

---

## **2. Configuring Image Build for Proxmox**  

### **Step 1: Create a Virtual Machine for Image Builder**  

Define the necessary Proxmox environment variables in `proxmox.env`:  

```bash
export PROXMOX_URL="https://pve.example.com:8006/api2/json"
export PROXMOX_USERNAME=<USERNAME>
export PROXMOX_TOKEN=<TOKEN_ID>
export PROXMOX_NODE="pve-main"
export PROXMOX_ISO_POOL="local"
export PROXMOX_BRIDGE="vmbr0"
export PROXMOX_STORAGE_POOL="local-zfs"
```

Export the environment variables:  

```bash
set -a
source proxmox.env
set +a
```

### **Step 2: Install Proxmox Dependencies**  

Install the required Proxmox dependencies:  

```bash
make deps-proxmox
```

### **Step 3: Modify Packer Configuration**  

Update the **Packer** configuration to change the disk format from `qcow2` to `raw`:  

```bash
vi packer/proxmox/packer.json.tmpl
```

### **Step 4: Build an Ubuntu 22.04 Image**  

Run the following command to build the **Ubuntu 22.04** image:  

```bash
make build-proxmox-ubuntu-2204
```

### **Step 5: Build an Ubuntu Image with a Custom Kubernetes Version**  

To build an **Ubuntu 22.04** image with a specific Kubernetes version:  

```bash
PACKER_FLAGS="--var 'kubernetes_rpm_version=1.28.3' --var 'kubernetes_semver=v1.28.3' --var 'kubernetes_series=v1.28' --var 'kubernetes_deb_version=1.28.3-1.1'" make build-proxmox-ubuntu-2204
```

For **Ubuntu 24.04** with Kubernetes **v1.32.2**:  

```bash
PACKER_FLAGS="--var 'kubernetes_semver=v1.32.2' --var 'kubernetes_series=v1.32.2' --var 'kubernetes_deb_version=1.32.2-1.1'" make build-proxmox-ubuntu-2404
```

---

## **3. ClusterAPI Configuration**  

### **Step 1: Install Clusterctl CLI**  

Install `clusterctl` using Homebrew:  

```bash
brew install clusterctl
```

### **Step 2: Configure Clusterctl**  

Modify `~/.cluster-api/clusterctl.yaml` with the following settings:  

```yaml
EXP_CLUSTER_RESOURCE_SET: "true" # Enables ClusterResourceSet for deploying CNI
CLUSTER_TOPOLOGY: "true"
PROXMOX_URL: "https://ip-host:8006"
PROXMOX_TOKEN: ''
PROXMOX_SECRET: ""
providers:
  - name: "kamaji"
    url: "https://github.com/clastix/cluster-api-control-plane-provider-kamaji/releases/v0.14.1/control-plane-components.yaml"
    type: "ControlPlaneProvider"
```

---

## **4. Initializing ClusterAPI**  

### **Step 1: Initialize ClusterAPI**  

Run the following command to initialize ClusterAPI with **Proxmox as the infrastructure provider** and **Kamaji as the control plane provider**:  

```bash
clusterctl init --infrastructure proxmox --ipam in-cluster --control-plane kamaji
```

### **Step 2: Retrieve the Kubeconfig for the Workload Cluster**  

Obtain the **kubeconfig** for the workload cluster using ClusterAPI:  

```bash
clusterctl get kubeconfig homelab-cluster -n clusters > kamaji/kubeconfig
```

---
