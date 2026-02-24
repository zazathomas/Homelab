terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      # This is a 'placeholder' name the module uses internally
      configuration_aliases = [ proxmox.pve_node ]
    }
  }
}