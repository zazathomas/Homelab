variable "vm_config" {
    default = {
      target_node: "pve-main"
      vm_name: "new-vm"
      vm_count: 1
      vmid: 300
      clone_from_vm: "Ubuntu-24.04"
      cores: 2
      memory: 2048
      balloon: 512
      disk_size: "20G"
      bios: "ovmf"
      disk_storage: "local-zfs"
      network_interface: "vmbr0"
      dns: "192.168.0.1"
      vm_state: "running"
      onboot: false
    }
  
}

variable "ciuser" {
  type = string
}

variable "cipassword" {
  type = string
}

variable "proxmox_api_token" {
  type = string
}

variable "proxmox_api_secret" {
  type = string
}