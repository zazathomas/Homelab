resource "proxmox_vm_qemu" "new_vm" {
  # VM configuration
  count = var.vm_config.vm_count
  name = "${var.vm_config.vm_name}-${count.index + 1}"
  vmid = var.vm_config.vmid + count.index + 1
  target_node = var.vm_config.target_node
  onboot = var.vm_config.onboot
  agent = 0
  boot = "order=scsi0"
  clone       = var.vm_config.clone_from_vm
  full_clone  = "true"
  bios = var.vm_config.bios
  scsihw = "virtio-scsi-pci"
  os_type = "cloud-init"
  cores = var.vm_config.cores
  memory = var.vm_config.memory
  balloon = var.vm_config.balloon
  sockets = 1
  numa = true
  vcpus = 0
  cpu_type = "host"
  vm_state = var.vm_config.vm_state

  # Cloud-init configuration
  ipconfig0 = "ip=dhcp"
  #ipconfig0 = "ip=192.168.0.6/32,gw=192.168.0.1"
  ciuser     = var.ciuser
  cipassword = var.cipassword
  nameserver = var.vm_config.dns
  ciupgrade  = true
  sshkeys = <<EOF
    ${file("~/.ssh/id_rsa.pub")}
  EOF

  # Serial configuration
  serial {
    id = 0
  }

  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
         size = var.vm_config.disk_size
         storage = var.vm_config.disk_storage
        }
      }
    }
    
    ide {
      ide2 {
        cloudinit {
          storage = var.vm_config.disk_storage
        }
      }
    }

  }

  # Network configuration
  network {
    id = 0
    bridge = var.vm_config.network_interface
    model  = "virtio"
  }

}

