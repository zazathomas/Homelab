# main.tf
locals {
  cmpt_name_prefix = "A506"
  time_f           = formatdate("HHmmss", timestamp())
}

 ############################################
 # Compute Instance
 ############################################
resource "oci_core_instance" "Teleport_Instance" {
  compartment_id      = var.compartment_id
  shape               = var.Teleport_Instance.shape.name
  availability_domain = var.Teleport_Instance.availability_domain
  display_name        = var.Teleport_Instance.display_name

  source_details {
    source_id   = var.Teleport_Instance.image_ocid
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = var.Teleport_Instance.shape.memory_in_gbs
      ocpus         = var.Teleport_Instance.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id                 = var.Teleport_Instance.subnet_id
    assign_public_ip          = var.Teleport_Instance.assign_public_ip
    assign_private_dns_record = var.Teleport_Instance.assign_private_dns_record
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for k in var.Teleport_Instance.ssh_authorized_keys : chomp(k)])
    # user_data           = "${base64encode(file("setup-teleport.sh"))}"
  }

  provisioner "file" {
    source      = "./files"
    destination = "/home/ubuntu/"
  }

  provisioner "remote-exec" {
    script = "./setup-teleport.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }
}


#esource "oci_core_instance" "Storage_Server" {
# compartment_id      = var.compartment_id
# shape               = var.Storage_Instance.shape.name
# availability_domain = var.Storage_Instance.availability_domain
# display_name        = var.Storage_Instance.display_name
#
# source_details {
#   source_id   = var.Storage_Instance.image_ocid
#   source_type = "image"
# }
#
# dynamic "shape_config" {
#   for_each = [true]
#   content {
#     #Optional
#     memory_in_gbs = var.Storage_Instance.shape.memory_in_gbs
#     ocpus         = var.Storage_Instance.shape.ocpus
#   }
# }
#
# create_vnic_details {
#   subnet_id                 = var.Storage_Instance.subnet_id
#   skip_source_dest_check    = var.Storage_Instance.skip_source_dest_check
#   assign_public_ip          = var.Storage_Instance.assign_public_ip
#   assign_private_dns_record = var.Storage_Instance.assign_private_dns_record
# }
#
# metadata = {
#   ssh_authorized_keys = join("\n", [for k in var.Storage_Instance.ssh_authorized_keys : chomp(k)]),
#   user_data           = base64encode("${file("install-storage.sh")}")
# }
#
