# This contains instructions for configuring cloud-init VM templates for my proxmox setup

1) Download the ISO using the GUI (tested on https://cloud-images.ubuntu.com/lunar/current/jammy-server-cloudimg-amd64-disk-kvm.img)
2) Create the VM via shell of the proxmox host
```qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0```
```cd /var/lib/vz/template/iso/```
```qm importdisk 5000 jammy-server-cloudimg-amd64-disk-kvm.img local-zfs```
```qm set 5000 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-5000-disk-0```
```qm set 5000 --ide2 local-zfs:cloudinit```
3) Expand the VM disk size to a suitable size (suggested 10 GB)
4) Create the Cloud-Init template
5) Deploy new VMs by cloning the template (full clone)