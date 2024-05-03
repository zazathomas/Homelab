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

variable "edge-security-group" {
  description = "The details of the security group"
  default = {
    display_name : "edge-security-group"
    description : "Security group for edge subnet"
  }
}

variable "ssh-sg-rule" {
  default = {
    direction      = "INGRESS"
    protocol       = "all"
    source_type    = "CIDR_BLOCK"
    source         = "0.0.0.0/0"
    local_source   = "172.16.0.0/16"
    port           = 22
  }
}
variable "outbound-sg-rule" {
  default = {
    direction      = "EGRESS"
    protocol       = "all"
    destination_type    = "CIDR_BLOCK"
    destination    = "0.0.0.0/0"
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
    ssh_authorized_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuzY9AR7LiJN8EhHeG3qP9gWuf7IxUl+xDaf1gD/zvZjid4Uxa8fRjWkAkeRQGa1ZNBLjw7EH+zWpjqOlCg14eZqTUnNtmOzIfK/LmcSFNKmD2rGNryY8DQBH5cY94bZVasOA+lhxnaNOzJ0sDGrqeCrpqTWqGWZ2NZ/nxXSXTdescHYcz/lmEijRLGnxtI/ByWKufowPUQm9gA0x+DRqJk9mvT7i1ZHi9djbeVPJPZthn14Ppi5cjLIXtCrxTQUcALaCPkzcgAKen9KHlmNRfoW+hx8fRxC0RPZgYCAigqz3hktsnjr+n4pxkF+5e55ZJJYdAKQnaYbS5SVzegC9jNzyzxef8JmZqtrgTBo4dsvNdbw7iIn0/KGgK3xZNTR55L60kS4y4NPbVNhRey8ESjIRc2zoBycssLmVd8cp0a0iLdjXDH3PGLgfC0Ly3Tv7lmGLd27c3U7ndN6ldXxFJ9k7B9k6EibyoaQJM0fLX4eug1tGa6BaB3dwEyZgSUuM= fdurrani@AJTV3VGQF2.local"]
  }
}

variable "Teleport_Instance" {
  description = "The details of the compute instance"
  default = {
    display_name : "Teleport_IAP"
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
    display_name : "Wazuh_Siem"
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
    display_name : "Docker_Host"
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

