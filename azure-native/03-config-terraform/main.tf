# Read Environment Variables
data "external" "env" { program = ["jq", "-n", "env"] }

# Create Terraform Project
resource "tfe_project" "this" {
  organization = var.organization_name
  name         = var.project_name
}

# Create Terraform Variable Set
resource "tfe_variable_set" "this" {
  name         = "vault-terraform-workload-identity"
  description  = "Vault-backed Workload Identity"
  organization = var.organization_name
}

resource "tfe_variable" "vault_addr" {
  key             = "TFC_VAULT_ADDR"
  value           = data.external.env.result.VAULT_ADDR
  category        = "env"
  description     = "Vault FQDN"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_namespace" {
  key             = "TFC_VAULT_NAMESPACE"
  value           = data.external.env.result.VAULT_NAMESPACE
  category        = "env"
  description     = "Vault Namespace"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "enable_vault_auth" {
  key             = "TFC_VAULT_PROVIDER_AUTH"
  value           = true
  category        = "env"
  description     = "Enable Vault Provider auth"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_run_role" {
  key             = "TFC_VAULT_RUN_ROLE"
  value           = var.terraform_auth_role
  category        = "env"
  description     = "Vault auth role"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_auth_path" {
  key             = "TFC_VAULT_AUTH_PATH"
  value           = var.terraform_auth_path
  category        = "env"
  description     = "Vault auth path"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_azure_auth" {
  key             = "TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE"
  value           = var.azure_secrets_engine_role
  category        = "env"
  description     = "Vault-backed Azure Auth role"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_azure_auth_role" {
  key             = "TFC_VAULT_BACKED_AZURE_AUTH"
  value           = true
  category        = "env"
  description     = "Enable Vault-backed Azure Dynamic Credentials"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_azure_auth_path" {
  key             = "TFC_VAULT_BACKED_AZURE_MOUNT_PATH"
  value           = var.azure_secrets_engine_path
  category        = "env"
  description     = "Azure Auth mount path"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_azure_sleep_seconds" {
  key             = "TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS"
  value           = 30
  category        = "env"
  description     = "Sleep Seconds"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
}

# Enable ability to create workspaces in any project
resource "tfe_team" "this" {
  name         = var.terraform_team_name
  organization = var.organization_name
  organization_access {
    manage_workspaces = true
    manage_projects   = true
  }
}

resource "tfe_team_token" "this" {
  team_id = tfe_team.this.id
}

resource "tfe_variable" "tfe_token" {
  key             = "TFE_TOKEN"
  value           = tfe_team_token.this.token
  category        = "env"
  description     = "tfe token"
  sensitive       = true
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "github_token" {
  key             = "GITHUB_TOKEN"
  value           = var.github_token
  category        = "env"
  description     = "github token"
  sensitive       = true
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_project" "demo_prod" {
  organization = var.organization_name
  name         = "demo-prod"
}

resource "tfe_project" "demo_dev" {
  organization = var.organization_name
  name         = "demo-dev"
}

resource "tfe_project" "demo_stage" {
  organization = var.organization_name
  name         = "demo-stage"
}