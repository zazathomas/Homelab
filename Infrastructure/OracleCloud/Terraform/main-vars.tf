variable "compartment_id" {
  description = "export TF_VAR_compartment_id=your-ocid"
  type        = string
}

############################################
# VCN
############################################

variable "vpc" {
  description = "The details of VPC."
  default = {
    cidr_blocks : ["172.16.0.0/16"]
    display_name : "cloud-vpc"
  }
}

############################################
# Public Subnet, Route Table, and Internet Gateway
############################################

variable "IGW" {
  description = "The details of the internet gateway"
  default = {
    display_name : "IGW"
    ig_destination = "0.0.0.0/0"
  }
}

variable "NATGW" {
  description = "The details of the nat gateway"
  default = {
    display_name : "NATGW"
    nat_destination = "0.0.0.0/0"
  }
}

variable "edge_subnet" {
  description = "The details of the subnet"
  default = {
    cidr_block : "172.16.1.0/24"
    display_name : "edge_subnet"
    prohibit_public_ip_on_vnic : false
    route_table : {
      display_name = "edge-route-table"
      description  = "Route table for public subnet"
    }
  }
}

variable "private_subnet" {
  description = "The details of the subnet"
  default = {
    cidr_block : "172.16.2.0/24"
    display_name : "private_subnet"
    prohibit_public_ip_on_vnic : true
    route_table : {
      display_name = "private-route-table"
      description  = "Route table for private subnet"
    }
  }
}

variable "lb_subnet" {
  description = "The details of the subnet"
  default = {
    cidr_block : "172.16.3.0/24"
    display_name : "lb_subnet"
    prohibit_public_ip_on_vnic : false
    route_table : {
      display_name = "edge-route-table"
      description  = "Route table for lb subnet"
    }
  }
}

variable "local_subnet" {
  default = {
    cidr_block       = "192.168.0.0/24"
    destination_type = "CIDR_BLOCK"
    description      = "Route to local home subnet"
    route_type       = "STATIC"
  }
}


variable "edge-security-group" {
  description = "Security group for public subnet"
  default = {
    display_name : "edge-security-group"
    description : "Security group for edge subnet"
  }
}

variable "lb-security-group" {
  description = "Security group for flexible load balancer"
  default = {
    display_name : "lb-security-group"
    description : "Security group for lb subnet"
  }
}

variable "ssh-sg-rule" {
  default = {
    direction    = "INGRESS"
    protocol     = "all"
    source_type  = "CIDR_BLOCK"
    source       = "0.0.0.0/0"
    local_source = "172.16.0.0/16"
    port         = 22
  }
}
variable "outbound-sg-rule" {
  default = {
    direction        = "EGRESS"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }
}

variable "lb-internet-inbound-sg-rule" {
  default = {
    direction   = "INGRESS"
    protocol    = "all"
    source_type = "CIDR_BLOCK"
    source      = "0.0.0.0/0"
  }
}

variable "lb-private-outbound-sg-rule" {
  default = {
    direction        = "EGRESS"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }
}

variable "lb-private-inbound-sg-rule" {
  default = {
    direction   = "INGRESS"
    protocol    = "all"
    source_type = "NETWORK_SECURITY_GROUP"
  }
}

variable "private-security-group" {
  description = "The details of the security group"
  default = {
    display_name : "private-security-group"
    description : "Security group for private subnet"
  }
}

############################################
# Compute Instances
############################################

variable "OCI_VGW_Tailscale" {
  description = "The details of the compute instance"
  default = {
    display_name : "Oracle-Cloud-VGW"
    assign_public_ip : true
    assign_private_dns_record : true
    availability_domain : "zjQw:US-ASHBURN-AD-1"
    image_ocid : "ocid1.image.oc1.iad.aaaaaaaalem66gdl6iqx6motorbtdjgaqkrilxzowiuyzfcghgcgsvvcukqa"
    skip_source_dest_check : true
    shape : {
      name          = "VM.Standard.E2.1.Micro"
      ocpus         = 1
      memory_in_gbs = 1
    }
    ssh_authorized_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCojZYUOR7C/xpGlYPRzBT67HRfxrQAwiNIuiOHreNmqJX1ltu4r+cU2DIQVcR9xUmOUpZ2c2w7V5gusEYoG4ANEr6bIbE5ZjQaeKEyGhVuCiJy0aMLZxZ06lkAyl3C4Gq+wHz1E3oV1xc0ydoRSsuZZPbzuQQrzFZ6PaZ9CbP4RvnskEvZILkiWO3qpXtx0FTvSfHauPDi27a5en7Jm0Si2FVMNo2C+HnlnTsZD7G9GlB8gD+fI0a7v942ttpvGO+nrPbOx18S17jmu7oGK80OmmHAYPcBbKZkHknC0pCmv3kMQHXdgj1OreiB7z+KPZPT3xX0IDh1XhCbrv49fcBe5UPcEVS2lkf4wzykmQDG9B3dUfRo+J6wiKLPbpf7lnLxXTSWgACGK9P4bhj8UoU5XdOefV2BEzx41qSjupx9i3NNGAZUb+DSN2dsraBEB/S4zXid+kRlvF92++3uFay0Wu7M/9KIx7KLe3jCjBEZCsc5wwlQnVhEOKx4asWFk9c= zaza@MacBook-Pro-2.local"]
  }
}

variable "Teleport_Instance" {
  description = "The details of the compute instance"
  default = {
    display_name : "Teleport"
    assign_public_ip : false
    assign_private_dns_record : true
    availability_domain : "zjQw:US-ASHBURN-AD-1"
    image_ocid : "ocid1.image.oc1.iad.aaaaaaaalem66gdl6iqx6motorbtdjgaqkrilxzowiuyzfcghgcgsvvcukqa"
    shape : {
      name          = "VM.Standard.E2.1.Micro"
      ocpus         = 1
      memory_in_gbs = 1
    }
  }
}

variable "Wazuh_Instance" {
  description = "The details of the compute instance"
  default = {
    display_name : "Wazuh"
    assign_public_ip : false
    assign_private_dns_record : true
    availability_domain : "zjQw:US-ASHBURN-AD-1"
    image_ocid : "ocid1.image.oc1.iad.aaaaaaaarjai52mxwgquk6qkrkvbbszjg2s5caqhdwekjzosek5zswjy2yoq"
    shape : {
      name          = "VM.Standard.A1.Flex"
      ocpus         = 2
      memory_in_gbs = 8
    }
  }
}

variable "Docker_Instance" {
  description = "The details of the compute instance"
  default = {
    display_name : "Docker"
    assign_public_ip : false
    assign_private_dns_record : true
    availability_domain : "zjQw:US-ASHBURN-AD-1"
    image_ocid : "ocid1.image.oc1.iad.aaaaaaaarjai52mxwgquk6qkrkvbbszjg2s5caqhdwekjzosek5zswjy2yoq"
    shape : {
      name          = "VM.Standard.A1.Flex"
      ocpus         = 2
      memory_in_gbs = 16
    }
  }
}

# ############################################
# # Flexible Load balancer
# ############################################

variable "load_balancer" {
  default = {
    display_name              = "flexible-lb"
    ip_mode                   = "IPV4"
    shape                     = "flexible"
    is_private                = false
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
    listener_name             = "teleport-listener"
    listener_protocol         = "TCP"
    listener_port             = 443
    backend_set_name          = "teleport-backend-set"
    backend_set_protocol      = "TCP"
    backend_set_port          = 443
    health_check_protocol     = "HTTP"
    health_check_port         = 3000
    health_check_url_path     = "/healthz"
    backend_set_policy        = "ROUND_ROBIN"
  }
}