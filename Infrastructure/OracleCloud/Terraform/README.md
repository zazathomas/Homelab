# OpenTofu

Who needs clicking around in the proxmox UI when you can spend hours writing a ~~Terraform~~OpenTofu config to spin up VMs for you. Whether you're building a rocket ship or setting up a K8s cluster, OpenTofu's got your back, automating away the drudgery so you can focus on the fun stuff, like sipping coffee and dreaming up your next big project. Say hello to OpenTofu and kiss those manual tasks goodbye!


https://dev.to/farisdurrani/setting-up-the-oci-configuration-file-using-api-keys-96c
Obtain API keys for OCI by navigating to Profile picture > My Profile > API keys > Add API key
Save public and private key
Paste the config file displayed on the screen into: ~/.oci/config

Inspiration
https://dev.to/farisdurrani/using-terraform-to-deploy-an-oci-compute-instance-harder-5c52

Oracle Cloud Terraform Provider docs: 
https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance

Find Image IDs
https://docs.oracle.com/en-us/iaas/images/image/6c21715a-0ab7-4a1c-81bd-ea13855f9505/


Remote backend terraform
https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm#s3


Secrets mgmt in terraform i.e https://spacelift.io/blog/terraform-secrets#step-1-use-a-secure-remote-backend
#Define variables for AWS access key, secret key, and region
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

Next, we set the corresponding environment variables in the format – TF_VAR_variable_name, where “variable_name” is the name of the input variables we defined in the previous step.

To do the same, run the below commands in the terminal with appropriate values.
export TF_VAR_aws_access_key=<access_key_value>
export TF_VAR_aws_secret_key=<secret_key_value>
export TF_VAR_aws_region=<region>        


