terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.96.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.10.1"
    }
  }
}


provider "proxmox" {
  alias = "pve-1"
  endpoint = "https://proxmox-01.local.z3cyber.tech:8006/"
  insecure = true
  api_token = var.api_token_secret_pve_1
}

provider "proxmox" {
  alias = "pve-2"
  endpoint = "https://proxmox-02.local.z3cyber.tech:8006/"
  insecure = true
  api_token = var.api_token_secret_pve_2
}