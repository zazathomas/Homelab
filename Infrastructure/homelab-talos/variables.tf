variable "backend_access_key" {
  description = "Access key for s3 backend"
  type = string
  sensitive = true
}

variable "backend_secret_key" {
  description = "secret key for s3 backend"
  type = string
  sensitive = true
}

variable "api_token_secret_pve_1" {
  description = "Token secret for pve-1 terraform user"
  type = string
  sensitive = true
}

variable "api_token_secret_pve_2" {
  description = "Token secret for pve-2 terraform user"
  type = string
  sensitive = true
}

variable "talos_version" {
  description = "Talos version for cluster"
  type = string
  default = "1.12.3"
}

variable "talos_installer_image" {
  description = "Talos installer image for cluster"
  type = string
  default = "factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.3"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy"
  type        = string
  default     = "v1.35.1"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default = "homelab-cluster"
}


variable "talos_nodes" {
    description = "List of talos node objects"
    default = [
    { hostname = "talos-master-1", ip_address = "192.168.0.231", role = "master", vm_id = 301, node_name = "pve-1", mac_address = "BC:24:11:96:E5:98" },
    { hostname = "talos-worker-1", ip_address = "192.168.0.232", role = "worker", vm_id = 302, node_name = "pve-1", mac_address = "BC:24:11:74:2A:B6" },
    { hostname = "talos-worker-2", ip_address = "192.168.0.233", role = "worker", vm_id = 303, node_name = "pve-1", mac_address = "BC:24:11:EA:C0:E3" },
    { hostname = "talos-master-2", ip_address = "192.168.0.234", role = "master", vm_id = 304, node_name = "pve-2", mac_address = "BC:24:11:85:EF:5A" },
    { hostname = "talos-master-3", ip_address = "192.168.0.235", role = "master", vm_id = 305, node_name = "pve-2", mac_address = "BC:24:11:E9:88:7E" },
    { hostname = "talos-worker-3", ip_address = "192.168.0.236", role = "worker", vm_id = 306, node_name = "pve-2", mac_address = "BC:24:11:E9:88:7F" },
  ]
}

variable "dns_servers" {
  description = "DNS servers for talos nodes"
  type = list(string)
  default = ["192.168.0.2", "1.1.1.1"]
}

variable "vip_ip" {
  description = "Shared IP address for talos master nodes"
  type = string
  default = "192.168.0.200"
}