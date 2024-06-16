locals {
    tfe_credentials = jsondecode(file("~/.terraform.d/credentials.tfrc.json"))
}