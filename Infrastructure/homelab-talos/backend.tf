terraform {
  backend "s3" {
    bucket = "terraform-statefiles"
    key    = "proxmox/homelab-talos/terraform.tfstate"
    region = "us-east-1"
    endpoints = {s3 = "https://d4f626e53977981652bb18a0948b046c.r2.cloudflarestorage.com"}
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    skip_s3_checksum = true
    use_path_style = true
  }
}