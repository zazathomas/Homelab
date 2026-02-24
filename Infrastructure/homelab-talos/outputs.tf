output "talosconfig" {
  value     = data.talos_client_configuration.talos_client_config.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.cluster_kubeconfig.kubeconfig_raw
  sensitive = true
}

# terraform output -raw talosconfig > secrets/talosconfig
# terraform output -raw kubeconfig > secrets/kubeconfig