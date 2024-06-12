## Azure Details
variable "azure_tenant_id" {
  type = string
}

variable "app_vault_client_id" {
  type = string
}

variable "app_vault_client_secret" {
  sensitive = true
  type      = string
}

variable "app_tfe_onboarding_object_id" {
  type = string
}

# JWT Auth Method for Terraform Workload Identity
variable "terraform_auth_path" {
  type = string
}

# Policy for Terraform Workload Identity
variable "terraform_auth_policy_name" {
  type = string
}

# JWT Auth Role for Terraform Workload Identity
variable "terraform_auth_role" {
  type = string
}

variable "terraform_addr" {
  type    = string
  default = "https://app.terraform.io"
}

variable "terraform_workspace_subject_identifier" {
  type = string
}

# Azure Secrets Engine
variable "azure_secrets_engine_path" {
  type = string
}

variable "azure_secrets_engine_role" {
  type = string
}