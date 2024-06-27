terraform {
  backend "s3" {
    bucket                      = "bucket-oci-terraform-state"
    region                      = "us-ashburn-1"
    key                         = "oracle-infra/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
    #insecure = true
    skip_metadata_api_check = true
    endpoints               = { s3 = "https://idzki3ip7oar.compat.objectstorage.us-ashburn-1.oraclecloud.com" }
    profile                 = "tfstate"
  }
}