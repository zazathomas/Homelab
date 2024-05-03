# main.tf
locals {
  cmpt_name_prefix = "A506"
  time_f           = formatdate("HHmmss", timestamp())
}


############################################
# VCN
############################################

resource "oci_core_vcn" "cloud-vpc" {
  #Required
  compartment_id = var.compartment_id
  cidr_blocks    = var.vpc.cidr_blocks
  #Optional
  display_name = var.vpc.display_name
}

############################################
# Subnets
############################################

resource "oci_core_subnet" "edge_subnet" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cloud-vpc.id
  cidr_block     = var.edge_subnet.cidr_block
  #Optional
  display_name               = var.edge_subnet.display_name
  prohibit_public_ip_on_vnic = var.edge_subnet.prohibit_public_ip_on_vnic
  route_table_id             = oci_core_route_table.edge_route_table.id
}

resource "oci_core_subnet" "private_subnet" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cloud-vpc.id
  cidr_block     = var.private_subnet.cidr_block
  #Optional
  display_name               = var.private_subnet.display_name
  prohibit_public_ip_on_vnic = var.private_subnet.prohibit_public_ip_on_vnic
  route_table_id             = oci_core_route_table.private_route_table.id
}

############################################
# Internet Gateways and NAT Gateways
############################################

resource "oci_core_internet_gateway" "IGW" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cloud-vpc.id
  display_name   = var.IGW.display_name
}

resource "oci_core_nat_gateway" "NATGW" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cloud-vpc.id
  display_name   = var.NATGW.display_name
}

############################################
# Route Tables
############################################

resource "oci_core_route_table" "edge_route_table" {
  #Required
  vcn_id         = oci_core_vcn.cloud-vpc.id
  compartment_id = var.compartment_id
  # Optional
  display_name = var.edge_subnet.route_table.display_name
  route_rules {
    destination       = var.IGW.ig_destination
    description       = var.edge_subnet.route_table.description
    network_entity_id = oci_core_internet_gateway.IGW.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  #Required
  vcn_id         = oci_core_vcn.cloud-vpc.id
  compartment_id = var.compartment_id
  # Optional
  display_name = var.private_subnet.route_table.display_name
  route_rules {
    destination       = var.NATGW.nat_destination
    description       = var.private_subnet.route_table.description
    network_entity_id = oci_core_nat_gateway.NATGW.id
  }
}

# ############################################
# # Security Groups and Rules
# ############################################

resource "oci_core_network_security_group" "edge-security-group" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cloud-vpc.id
  #Optional
  display_name = var.edge-security-group.display_name
}
# Rules for Edge SG
resource "oci_core_network_security_group_security_rule" "Tailscale-SG-Rule-SSH" {
  network_security_group_id = oci_core_network_security_group.edge-security-group.id
  direction      = var.ssh-sg-rule.direction
  protocol       = var.ssh-sg-rule.protocol
  source_type    = var.ssh-sg-rule.source_type
  source         = var.ssh-sg-rule.source
}

resource "oci_core_network_security_group_security_rule" "Tailscale-SG-Rule-outbound" {
  network_security_group_id = oci_core_network_security_group.edge-security-group.id
  direction      = var.outbound-sg-rule.direction
  protocol       = var.outbound-sg-rule.protocol
  destination_type    = var.outbound-sg-rule.destination_type
  destination         = var.outbound-sg-rule.destination
}

resource "oci_core_network_security_group" "private-security-group" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.cloud-vpc.id
  #Optional
  display_name = var.private-security-group.display_name
}

# Rules for Private SG
resource "oci_core_network_security_group_security_rule" "private-SG-Rule-outbound" {
  network_security_group_id = oci_core_network_security_group.private-security-group.id
  direction      = var.outbound-sg-rule.direction
  protocol       = var.outbound-sg-rule.protocol
  destination_type    = var.outbound-sg-rule.destination_type
  destination         = var.outbound-sg-rule.destination
}

resource "oci_core_network_security_group_security_rule" "Local-SG-Rule-SSH" {
  network_security_group_id = oci_core_network_security_group.private-security-group.id
  direction      = var.ssh-sg-rule.direction
  protocol       = var.ssh-sg-rule.protocol
  source_type    = var.ssh-sg-rule.source_type
  source         = var.ssh-sg-rule.local_source
}

# ############################################
# # Compute Instance
# ############################################

resource "oci_core_instance" "OCI_VGW_Tailscale" {
  compartment_id      = var.compartment_id
  shape               = var.OCI_VGW_Tailscale.shape.name
  availability_domain = var.OCI_VGW_Tailscale.availability_domain
  display_name        = var.OCI_VGW_Tailscale.display_name

  source_details {
    source_id   = var.OCI_VGW_Tailscale.image_ocid
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = var.OCI_VGW_Tailscale.shape.memory_in_gbs
      ocpus         = var.OCI_VGW_Tailscale.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.edge_subnet.id
    skip_source_dest_check = var.OCI_VGW_Tailscale.skip_source_dest_check
    assign_public_ip = var.OCI_VGW_Tailscale.assign_public_ip
    assign_private_dns_record = var.OCI_VGW_Tailscale.assign_private_dns_record
    nsg_ids = [oci_core_network_security_group.edge-security-group.id]
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for k in var.OCI_VGW_Tailscale.ssh_authorized_keys : chomp(k)])
  }
}


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
    subnet_id = oci_core_subnet.private_subnet.id
    assign_public_ip = var.Teleport_Instance.assign_public_ip
    assign_private_dns_record = var.Teleport_Instance.assign_private_dns_record
    nsg_ids = [oci_core_network_security_group.private-security-group.id]
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for k in var.OCI_VGW_Tailscale.ssh_authorized_keys : chomp(k)])
  }
}

resource "oci_core_instance" "Wazuh_Instance" {
  compartment_id      = var.compartment_id
  shape               = var.Wazuh_Instance.shape.name
  availability_domain = var.Wazuh_Instance.availability_domain
  display_name        = var.Wazuh_Instance.display_name

  source_details {
    source_id   = var.Wazuh_Instance.image_ocid
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = var.Wazuh_Instance.shape.memory_in_gbs
      ocpus         = var.Wazuh_Instance.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.private_subnet.id
    assign_public_ip = var.Wazuh_Instance.assign_public_ip
    assign_private_dns_record = var.Wazuh_Instance.assign_private_dns_record
    nsg_ids = [oci_core_network_security_group.private-security-group.id]
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for k in var.OCI_VGW_Tailscale.ssh_authorized_keys : chomp(k)])
  }
}


resource "oci_core_instance" "Docker_Instance" {
  compartment_id      = var.compartment_id
  shape               = var.Docker_Instance.shape.name
  availability_domain = var.Docker_Instance.availability_domain
  display_name        = var.Docker_Instance.display_name

  source_details {
    source_id   = var.Docker_Instance.image_ocid
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = var.Docker_Instance.shape.memory_in_gbs
      ocpus         = var.Docker_Instance.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.private_subnet.id
    assign_public_ip = var.Docker_Instance.assign_public_ip
    assign_private_dns_record = var.Docker_Instance.assign_private_dns_record
    nsg_ids = [oci_core_network_security_group.private-security-group.id]
  }

  metadata = {
    ssh_authorized_keys = join("\n", [for k in var.OCI_VGW_Tailscale.ssh_authorized_keys : chomp(k)])
  }
}
