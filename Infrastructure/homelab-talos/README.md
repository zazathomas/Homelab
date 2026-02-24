# Talos Cluster on Proxmox with Terraform

This repository deploys a Talos Kubernetes cluster on Proxmox using Terraform.
It provisions VMs, generates Talos configs, bootstraps the control plane, and produces a kubeconfig.

## Repository Layout

```
.
├── README.md
├── backend.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── talos_cluster.tf
├── bootstrap-apps/
│   ├── argocd.yaml
│   └── cilium.yaml
├── patches/
├── secrets/
```

### Key Components

* **providers.tf** – Proxmox and Talos providers
* **backend.tf** – Terraform state configuration
* **talos_cluster.tf** – Cluster definition and Talos bootstrap
* **patches/** – Talos machine configuration patches
* **bootstrap-apps/** – Kubernetes manifests applied at bootstrap
* **secrets/** – Generated Talos secrets (ignored by git)

---

# Prerequisites

Install the following tools:

* Terraform
* talosctl
* kubectl
* Access to Proxmox API
* Talos ISO uploaded to Proxmox

You should also have:

* A Proxmox cluster (e.g. `pve-1`, `pve-2`)
* Static DHCP leases or predefined IPs
* A Virtual IP for the control plane

---

# Configuration

## 1. Configure Providers

Update `providers.tf` with your Proxmox endpoints:

```hcl
provider "proxmox" {
  alias = "pve-1"
}

provider "proxmox" {
  alias = "pve-2"
}
```

---

## 2. Define Cluster Variables

Edit `variables.tf` or create a `terraform.tfvars`.

Example:

```hcl
cluster_name        = "talos-cluster"
talos_version       = "1.7.5"
kubernetes_version  = "1.30.1"
vip_ip              = "192.168.1.10"
dns_servers         = ["192.168.1.1"]

talos_nodes = [
  {
    hostname   = "cp-1"
    role       = "master"
    vm_id      = 100
    node_name  = "pve-1"
    ip_address = "192.168.1.101"
  },
  {
    hostname   = "cp-2"
    role       = "master"
    vm_id      = 101
    node_name  = "pve-2"
    ip_address = "192.168.1.102"
  },
  {
    hostname   = "worker-1"
    role       = "worker"
    vm_id      = 200
    node_name  = "pve-1"
    ip_address = "192.168.1.201"
  }
]
```

---

# Deployment

## 1. Initialize Terraform

```bash
terraform init
```

---

## 2. Review Plan

```bash
terraform plan
```

This will:

* Create Talos VMs on Proxmox
* Generate Talos configs
* Apply configuration
* Bootstrap etcd
* Generate kubeconfig

---

## 3. Apply

```bash
terraform apply
```

---

# Talos Bootstrap Flow

The cluster is created in this order:

1. VMs created on Proxmox
2. Talos secrets generated
3. Machine configs generated
4. Configs applied to nodes
5. etcd bootstrapped
6. kubeconfig generated

---

# Accessing the Cluster

After apply completes:

```bash
terraform output kubeconfig > kubeconfig
export KUBECONFIG=./kubeconfig
```

Verify:

```bash
kubectl get nodes
```

---

# Talos Access

Generate talosconfig:

```bash
terraform output talosconfig > talosconfig
export TALOSCONFIG=./talosconfig
```

Check nodes:

```bash
talosctl get members
```

---

# VM Configuration

VM specs are determined by role:

| Role   | CPU | RAM  | Disk |
| ------ | --- | ---- | ---- |
| Master | 16  | 6GB  | 30GB |
| Worker | 16  | 12GB | 40GB |

Overrides can be set per node.

---

# Configuration Patches

Talos configuration is modified using patches:

```
patches/
├── cni.yaml
├── dhcp.yaml
├── vip.yaml
└── ...
```

These are applied automatically during provisioning.

---

# Bootstrapped Applications

Bootstrap manifests live in:

```
bootstrap-apps/
```

Typical apps include:

* Cilium
* ArgoCD

---

# Destroying the Cluster

```bash
terraform destroy
```

This removes:

* All VMs
* Talos configs
* Cluster state

---

# Notes

* First master node is used for bootstrap
* VIP must be reachable
* Nodes must be able to reach each other
* Talos ISO must exist on each Proxmox node

---

# Troubleshooting

Check node status:

```bash
talosctl health
```

Check Kubernetes:

```bash
kubectl get pods -A
```

If bootstrap fails:

```bash
talosctl logs etcd
```