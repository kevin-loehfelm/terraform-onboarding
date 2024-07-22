/*******************************************
Environment Configuration
*******************************************/
# Variable(s): Resource Prefix
variable "prefix" {
  type        = string
  description = "environment prefix"
  default     = "demo"
}

# Variable(s): Default TTL for dynamic credentials (defualt: 300)
variable "default_ttl" {
  type    = number
  default = 300
}

# Variable(s): Max TTL for dynamic credentials (defualt: 600)
variable "max_ttl" {
  type    = number
  default = 600
}

/*******************************************
Azure Configuration Variables
*******************************************/
# Variable(s): Azure Application Name for Vault Azure Secrets Engine
variable "azure_app_azure_secrets_engine" {
  type        = string
  description = "azure application name for vault azure secrets engine"
  default     = "vault-azure-secrets-engine"
}

# Variable(s): Azure Application Name for Azure Project Onboarding
variable "azure_app_onboarding" {
  type        = string
  description = "azure application name for azure project onboarding"
  default     = "vault-azure-project-onboarding"
}

/*******************************************
Terraform Configuration Variables
*******************************************/
# Variable(s): Terraform token
variable "terraform_token" {
  type        = string
  description = "terraform token"
  sensitive   = true
}

# Variable(s): Terraform FQDN
variable "terraform_addr" {
  type        = string
  description = "terraform fqdn"
  default     = "https://app.terraform.io"
}

# Variable(s): Terraform Organization Name for Azure Project Onboarding OIDC bound claims
variable "terraform_org_name" {
  type        = string
  description = "terraform organization name"
}

# Variable(s): Terraform Project Name for Azure Project Onboarding OIDC bound claims
variable "terraform_onboarding_project_name" {
  type        = string
  description = "terraform project name: custom, *"
  default     = "azure-onboarding"
}

# Variable(s): Terraform Variable Set for Azure Project Onboarding
variable "terraform_variable_set_name" {
  type        = string
  description = "terraform variable set for azure project onboarding"
  default     = "vault-azure-project-onboarding"
}

/*******************************************
Vault Configuration Variables
*******************************************/
# Variable(s): Vault Address
variable "vault_addr" {
  type        = string
  description = "vault address"
}

# Variable(s): Vault Namespace
variable "vault_namespace" {
  type        = string
  description = "vault namespace"
  default     = ""
}

# Variable(s): Vault jwt auth path for Azure Project Onboarding
variable "vault_auth_path" {
  type        = string
  description = "vault auth path for jwt auth"
  default     = "terraform"
}

# Variable(s): Vault Policy Name
variable "vault_policy_name" {
  type        = string
  description = "vault policy name for terraform workload identity"
  default     = "azure_project_onboarding"
}

# Variable(s): Vault jwt auth role for Azure Project Onboarding
variable "vault_auth_role_name" {
  type        = string
  description = "vault auth role for azure project onboarding"
  default     = "azure_project_onboarding"
}

# Variable(s): Vault azure Secrets Engine Path
variable "vault_azure_secrets_path" {
  type        = string
  description = "vault azure secrets mount path"
  default     = "azure"
}

# Variable(s): Vault azure Secrets Engine Role for Azure Project Onboarding
variable "vault_azure_secrets_role" {
  type        = string
  description = "vault azure secrets role"
  default     = "azure_project_onboarding"
}

# Variable(s): Vault terraform cloud Secrets Engine Path
variable "vault_terraform_secrets_path" {
  type        = string
  description = "hcp terraform secrets mount path"
  default     = "terraform"
}

# Variable(s): Vault terraform cloud Secrets Engine Role for Azure Project Onboarding
variable "vault_terraform_secrets_role" {
  type        = string
  description = "hcp terraform secrets role"
  default     = "azure_project_onboarding"
}

# Variable(s): Vault KVv2 Secrets Engine Path
variable "vault_static_secrets_path" {
  type        = string
  description = "kvv2 static secrets mount path"
  default     = "static"
}

# Variable(s): Vault KVv2 Secret for GitHub token
variable "vault_static_github_key" {
  type        = string
  description = "kvv2 static secrets key"
  default     = "github"
}

# Variable(s): Vault KVv2 Secret for GitHub token
# TODO: Workaround for dynamic credentials permission issue
variable "vault_static_terraform_key" {
  type        = string
  description = "kvv2 static secrets key"
  default     = "terraform"
}

/*******************************************
GitHub Configuration Variables
*******************************************/

# Variable(s): GitHub Organization
variable "github_organization" {
  type        = string
  description = "github organization name"
}

# Variable(s): GitHub token
variable "github_token" {
  type        = string
  description = "github token"
  sensitive   = true
}

# Variable(s): GitHub Workspace Module Repo for Onboarding with Azure Native Dynamic Credentials
variable "github_repo_azure_native" {
  type = string
}

# Variable(s): GitHub Workspace Module Repo for Onboarding with Vault-Backed Azure Dynamic Credentials with existing Service Principals
variable "github_repo_azure_vault_static" {
  type = string
}

# Variable(s): GitHub Workspace Module Repo for Onboarding with Vault-Backed Azure Dynamic Credentials with dynamic Service Principals
variable "github_repo_azure_vault_dynamic" {
  type = string
}