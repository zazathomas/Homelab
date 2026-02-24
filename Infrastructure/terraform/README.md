# Terraform Permissions Setup for Proxmox

This guide explains how to configure permissions for Terraform on Proxmox and then apply a Terraform configuration to create virtual machines.

It covers:
- Creating a Terraform role
- Creating a Terraform user
- Assigning permissions
- Creating an API token
- Configuring Terraform
- Applying Terraform configuration

This setup is intended for use with Terraform and Proxmox VE.

---

# 1. Create a Terraform Role

Log into your Proxmox server via SSH and create a role for Terraform:

```bash
pveum role add terraform-role -privs "SDN.Use Pool.Audit Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
````

## Permissions Included

This role allows Terraform to:

* Create virtual machines
* Clone templates
* Modify VM hardware
* Allocate storage
* Configure networking
* Power manage VMs
* Monitor VM status

---

# 2. Create a Terraform User

Create a dedicated user for Terraform:

```bash
pveum user add terraform-user@pve --password password
```

Example:

```bash
pveum user add terraform-user@pve --password StrongPasswordHere
```

---

# 3. Assign the Role

Assign the Terraform role to the user:

```bash
pveum aclmod / -user terraform-user@pve -role terraform-role
```

This grants Terraform permissions across the entire Proxmox cluster.

---

# 4. Create an API Token (Recommended)

Terraform works best with API tokens instead of passwords.

Create a token:

```bash
pveum user token add terraform-user@pve terraform-token --privsep=0
```

Example output:

```
terraform-user@pve!terraform-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Save this token securely.

---

# 5. Configure Terraform Provider

Create a file named:

```
main.tf
```

Example provider configuration:

```hcl
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://your-proxmox:8006/api2/json"

  pm_api_token_id     = "terraform-user@pve!terraform-token"
  pm_api_token_secret = "YOUR_SECRET"

  pm_tls_insecure = true
}
```

Replace:

* `your-proxmox` with your Proxmox IP or hostname
* `YOUR_SECRET` with your API token secret

---

# 6. Example VM Configuration

Example virtual machine resource:

```hcl
resource "proxmox_vm_qemu" "test_vm" {
  name        = "terraform-test"
  target_node = "pve"

  clone = "template-vm"

  cores  = 2
  memory = 2048

  disk {
    size    = "20G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}
```

---

# 7. Initialize Terraform

Run:

```bash
terraform init
```

---

# 8. Validate Configuration

```bash
terraform validate
```

---

# 9. Plan Deployment

```bash
terraform plan
```

---

# 10. Apply Configuration

```bash
terraform apply
```

Type:

```
yes
```

Terraform will create the VM in Proxmox.

---

# 11. Verify Deployment

Log into the Proxmox web interface and confirm the VM was created.

---

# 12. Optional: Test API Access

You can test the API token with:

```bash
curl -k \
  -H "Authorization: PVEAPIToken=terraform-user@pve!terraform-token=YOUR_SECRET" \
  https://your-proxmox:8006/api2/json/nodes
```

---

# Summary

## Create Role

```bash
pveum role add terraform-role -privs "SDN.Use Pool.Audit Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
```

## Create User

```bash
pveum user add terraform-user@pve --password password
```

## Assign Role

```bash
pveum aclmod / -user terraform-user@pve -role terraform-role
```

## Create Token

```bash
pveum user token add terraform-user@pve terraform-token --privsep=0
```

---

# Notes

* Use API tokens instead of passwords where possible.
* Store secrets securely.
* Restrict permissions if full cluster access is not required.
