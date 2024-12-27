# This contains instructions for configuring cloud-init VM templates for my proxmox setup

1) Download the ISO using the GUI (tested on https://cloud-images.ubuntu.com/lunar/current/jammy-server-cloudimg-amd64-disk-kvm.img)
2) Create the VM via shell of the proxmox host
```qm create 5001 --memory 10240 --core 16 --name Ubuntu 24.04 --net0 virtio,bridge=vmbr0```
```cd /var/lib/vz/template/iso/```
```qm importdisk 5001 noble-server-cloudimg-amd64.img local-zfs```
```qm set 5001 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-5001-disk-0```
```qm set 5001 --ide2 local-zfs:cloudinit```
```qm set 5001 --boot c --bootdisk scsi0```
```qm set 5001 --serial0 socket --vga serial0```
3) Expand the VM disk size to a suitable size (suggested 10 GB)
4) modify the cloudinit-tab
5) Create the Cloud-Init template
6) Deploy new VMs by cloning the template (full clone)


