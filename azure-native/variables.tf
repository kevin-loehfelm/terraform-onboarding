/*******************************************
Azure Configuration Variables
*******************************************/
variable "azure_application_name" {
  type        = string
  description = "azure application name"
  default     = "terraform-azure-native"
}

/*******************************************
Terraform Configuration Variables
*******************************************/
variable "terraform_addr" {
  type        = string
  description = "terraform fqdn | default: https://app.terraform.io"
  default     = "https://app.terraform.io"
}

variable "terraform_org_name" {
  type        = string
  description = "terraform organization name"
}

variable "terraform_project_name" {
  type        = string
  description = "terraform project name: custom, *"
}

variable "terraform_workspace_name" {
  type        = string
  description = "terraform workspace name: custom, *"
}

variable "terraform_run_phase" {
  type        = string
  description = "terraform run phase: plan, apply, *"
}

variable "terraform_token_ttl" {
  type    = number
  default = 300
}

/*******************************************
Vault Configuration Variables
*******************************************/
variable "vault_auth_path" {
  type        = string
  description = "vault auth path for jwt auth | default: terraform_jwt"
  default     = "terraform_jwt"
}

variable "vault_policy_name" {
  type        = string
  description = "vault policy name for terraform dynamic credentials | default: terraform_dynamic_credentials"
  default     = "terraform_dynamic_credentials"
}

variable "vault_auth_role_name" {
  type        = string
  description = "vault auth role for terraform dynamic credentials | default: terraform_admin"
  default     = "terraform_admin"
}

variable "vault_azure_secrets_engine_path" {
  type        = string
  description = "vault azure secrets engine mount path | default: azure-native"
  default     = "azure-native"
}

/*******************************************
GitHub Configuration Variables
*******************************************/
variable "github_token" {
  type        = string
  description = "github token"
  sensitive   = true
}

variable "github_workspace_module_repo" {
  type    = string
  default = "kevin-loehfelm/terraform-demo-project"
}