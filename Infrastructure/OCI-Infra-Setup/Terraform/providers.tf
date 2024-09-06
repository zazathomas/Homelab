terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.39.0"
    }
  }
}

# provider.tf
provider "oci" {
  config_file_profile = "DEFAULT"
}