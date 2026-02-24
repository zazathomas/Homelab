variable "nodes" {
  description = "List of node objects to create"
  type = list(object({
    hostname             = string
    role             = string # "master" or "worker"
    vm_id            = number
    node_name        = string # proxmox node (pve-1, pve-2, etc)
    mac_address      = optional(string, null)
    ip_address      = optional(string, null)
    # Optional overrides
    started = optional(bool, true)
    cpu_cores        = optional(number)
    memory_dedicated = optional(number)
    memory_floating  = optional(number)
    disk_size_gb     = optional(number)
  }))
}

locals {
  # Define your standard hardware tiers here
  role_defaults = {
    master = {
      cpu    = 16
      mem_d  = 6144
      mem_f  = 2048
      disk   = 30
    }
    worker = {
      cpu    = 16
      mem_d  = 12288
      mem_f  = 3072
      disk   = 40
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos" {
  # We convert the list to a map using the VM name as the key
  for_each = { for node in var.nodes : node.hostname => node }
  
  # Dynamic Provider Assignment (must be passed via 'providers' in module call)
  provider = proxmox.pve_node

  name      = each.value.hostname
  node_name = each.value.node_name
  vm_id     = each.value.vm_id
  tags      = [each.value.role, "talos-k8s", "k8s", each.value.node_name]
  stop_on_destroy = true
  started = each.value.started

  cpu {
    # Use override if provided, else use role default
    cores = coalesce(each.value.cpu_cores, local.role_defaults[each.value.role].cpu)
    type  = "host"
    numa = true
    sockets = 1
  }

  memory {
    dedicated = coalesce(each.value.memory_dedicated, local.role_defaults[each.value.role].mem_d)
    floating  = coalesce(each.value.memory_floating, local.role_defaults[each.value.role].mem_f)
  }

  disk {
    interface    = "virtio0"
    size         = coalesce(each.value.disk_size_gb, local.role_defaults[each.value.role].disk)
    # Node-specific storage logic
    datastore_id = each.value.node_name == "pve-2" ? "local-zfs" : "local-zfs"
    replicate = false
  }

  network_device {
    enabled     = true
    mac_address = try(each.value.mac_address, null)
    model = "virtio"
    firewall = false
  }

  # Static Talos settings
  bios = "seabios"
  machine = "q35"
  scsi_hardware = "virtio-scsi-pci"

  cdrom {
    file_id   = each.value.node_name == "pve-2" ? "local:iso/nocloud-amd64.iso" : "isos:iso/nocloud-amd64.iso"
    interface = "ide2"
  }
  
  agent {
     enabled = true
   }

   boot_order = ["virtio0", "ide2"]
}