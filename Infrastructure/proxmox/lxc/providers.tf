terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url = "http://proxmox.local.z3cyber.tech/api2/json"
  pm_api_token_id = var.proxmox_api_token
  pm_api_token_secret = var.proxmox_api_secret
  pm_tls_insecure = true
}