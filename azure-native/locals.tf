# Local(s): Read Terraform Credentials from host configuration
locals {
  tfe_credentials = jsondecode(file("~/.terraform.d/credentials.tfrc.json"))
}