IMG_PATH="/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img"
VM_ID=5001
VM_NAME="Ubuntu-24.04"
VM_DISK_SIZE=10G
VM_DISK_FORMAT="qcow2"
VM_MEMORY=10240
VM_CORES=16

# Create the VM
qm create $VM_ID --memory $VM_MEMORY --cores $VM_CORES --name $VM_NAME --net0 virtio,bridge=vmbr0

# Import the disk and attach it as virtio
qm importdisk $VM_ID $IMG_PATH local-zfs
qm set $VM_ID --virtio0 local-zfs:vm-$VM_ID-disk-0

# Attach cloud-init drive
qm set $VM_ID --ide2 local-zfs:cloudinit

# Set boot device to virtio0
qm set $VM_ID --boot c --bootdisk virtio0

# Set serial console and display
qm set $VM_ID --serial0 socket --vga serial0