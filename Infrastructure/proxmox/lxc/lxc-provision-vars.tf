variable "lxc_config" {
    default = {
      target_node: "pve-main"
      hostname: "new-lxc"
      vmid: 0
      ostemplate: "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
      cores: 16
      memory: 2048
      swap: 512
      disk_size: "2G"
      disk_storage: "local-zfs"
      network_interface: "vmbr0"
      dns: "192.168.0.1"
      onboot: false
      start: true
    }
  
}

variable "password" {
  type = string
}

variable "proxmox_api_token" {
  type = string
}

variable "proxmox_api_secret" {
  type = string
}