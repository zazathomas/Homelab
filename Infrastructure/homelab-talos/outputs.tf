output "talosconfig" {
  value     = data.talos_client_configuration.talos_client_config.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.cluster_kubeconfig.kubeconfig_raw
  sensitive = true
}

output "controlplane_config" {
  value     = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive = true
}

output "worker_config" {
  value     = data.talos_machine_configuration.worker.machine_configuration
  sensitive = true
}

output "worker_gpu_config" {
  value     = data.talos_machine_configuration.worker_gpu.machine_configuration
  sensitive = true
}

# terraform output -raw talosconfig > secrets/talosconfig
# terraform output -raw kubeconfig > secrets/kubeconfig
# terraform output -raw controlplane_config > secrets/controlplane_config
# terraform output -raw worker_config > secrets/worker_config
# terraform output -raw worker_gpu_config > secrets/worker_gpu_config