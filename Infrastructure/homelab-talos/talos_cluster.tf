locals {
  pve-1-nodes = [
    for node in var.talos_nodes: node if node.node_name == "pve-1"
  ]
  pve-2-nodes = [
    for node in var.talos_nodes: node if node.node_name == "pve-2"
  ]
  master_nodes = {
    for node in var.talos_nodes : node.hostname => node if node.role == "master"
  }
  worker_nodes = {
    for node in var.talos_nodes : node.hostname => node if node.role == "worker"
  }
  masters_list = [ for node in var.talos_nodes : node.ip_address if node.role == "master" ]
  all_nodes_list = [ for node in var.talos_nodes: node.ip_address ]
}

module "pve1_nodes" {
  source    = "./../terraform/modules/talos_vm"
  providers = { proxmox.pve_node = proxmox.pve-1 }
  

  nodes = local.pve-1-nodes
}


module "pve2_nodes" {
  source    = "./../terraform/modules/talos_vm"
  providers = { proxmox.pve_node = proxmox.pve-2 }
  
  nodes = local.pve-2-nodes
}

resource "talos_machine_secrets" "talos" {
  depends_on = [ module.pve1_nodes, module.pve2_nodes ]
  talos_version = "v${var.talos_version}"
}

data "talos_client_configuration" "talos_client_config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints = local.masters_list
  nodes                = local.all_nodes_list
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${var.vip_ip}:6443"
  machine_secrets  = talos_machine_secrets.talos.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version = var.talos_version
  config_patches = [ 
    yamlencode({
      machine = {
        install = {
          image = var.talos_installer_image
        }
      }
    }),
    file("${path.module}/patches/allow-cp-lb.yaml"),
    file("${path.module}/patches/allow-cp-workloads.yaml"),
    file("${path.module}/patches/cni.yaml"),
    file("${path.module}/patches/dhcp.yaml"),
    file("${path.module}/patches/disable-kubeproxy.yaml"),
    file("${path.module}/patches/cni.yaml"),
    file("${path.module}/patches/extra-manifests.yaml"),
    file("${path.module}/patches/install-disk.yaml"),
    file("${path.module}/patches/interface-names.yaml"),
    file("${path.module}/patches/kubelet-certs.yaml"),
    file("${path.module}/patches/machine-certSANs.yaml"),
    file("${path.module}/patches/vip.yaml"),
    file("${path.module}/patches/hostname-config.yaml"),
   ]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = "https://${var.vip_ip}:6443"
  machine_secrets  = talos_machine_secrets.talos.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version = var.talos_version
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = var.talos_installer_image
        }
      }
    }),
    file("${path.module}/patches/cni.yaml"),
    file("${path.module}/patches/dhcp.yaml"),
    file("${path.module}/patches/disable-kubeproxy.yaml"),
    file("${path.module}/patches/install-disk.yaml"),
    file("${path.module}/patches/interface-names.yaml"),
    file("${path.module}/patches/kubelet-certs.yaml"),
    file("${path.module}/patches/hostname-config.yaml"),
   ]
}

resource "talos_machine_configuration_apply" "apply_talos_control_planes" {
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = local.master_nodes
  node                        = each.value.ip_address
  config_patches = [
    yamlencode({
      machine = {
        network = {
          nameservers = var.dns_servers
        }
      }
    }),
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "HostnameConfig"
      hostname   = each.value.hostname
      auto       = "off"
    })
  ]
}

resource "talos_machine_configuration_apply" "apply_talos_workers" {
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = local.worker_nodes
  node                        = each.value.ip_address
  config_patches = [
    yamlencode({
      machine = {
        network = {
          nameservers = var.dns_servers
        }
      }
    }),
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "HostnameConfig"
      hostname   = each.value.hostname
      auto       = "off"
    })
  ]
}

resource "talos_machine_bootstrap" "etcd_bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.apply_talos_control_planes
  ]
  node                 = local.masters_list[0]
  client_configuration = talos_machine_secrets.talos.client_configuration
}

resource "talos_cluster_kubeconfig" "cluster_kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.etcd_bootstrap
  ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = local.masters_list[0]
}