# Proxmox Cloud-Init VM template

These steps create an Ubuntu 24.04 Cloud-Init template on Proxmox. Adjust the VM ID, resources, storage, and network bridge for the target host.

## Download the image

Download the current Ubuntu Noble cloud image from the Ubuntu cloud images site:

<https://cloud-images.ubuntu.com/noble/current/>

Use the exact filename downloaded in the following `qm importdisk` command. The examples below use `noble-server-cloudimg-amd64.img`.

## Create the template VM

Run these commands on the Proxmox host:

```bash
qm create 5001 \
  --memory 10240 \
  --cores 16 \
  --name Ubuntu-24.04 \
  --net0 virtio,bridge=vmbr0

cd /var/lib/vz/template/iso
qm importdisk 5001 noble-server-cloudimg-amd64.img local-zfs
qm set 5001 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-5001-disk-0
qm set 5001 --ide2 local-zfs:cloudinit
qm set 5001 --boot c --bootdisk scsi0
qm set 5001 --serial0 socket --vga serial0
```

Expand the imported disk to the required size before converting the VM to a template. Ten GiB is only a starting point; choose a size appropriate for the operating system and workload.

## Configure and clone

1. Open the VM's **Cloud-Init** tab and set the user, SSH key, network configuration, and DNS settings.
2. Regenerate the Cloud-Init drive and boot the VM once to verify the configuration.
3. Shut the VM down and convert it to a template.
4. Create full clones from the template.
5. Give every clone a unique hostname and network identity before joining it to a cluster.
