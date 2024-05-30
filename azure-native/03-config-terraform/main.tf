# Read environment variables
data "external" "env" { program = ["jq", "-n", "env"] }

# Create Terraform Project
resource "tfe_project" "this" {
  organization = var.terraform_org_name
  name         = var.terraform_project_name
}

# Create Terraform Variable Set
resource "tfe_variable_set" "this" {
  name         = "vault-dynamic-credentials"
  description  = "Vault-backed Dynamic Credentials"
  organization = var.terraform_org_name
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
  value           = var.vault_auth_role_name
  category        = "env"
  description     = "Vault auth role"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "vault_auth_path" {
  key             = "TFC_VAULT_AUTH_PATH"
  value           = var.vault_auth_path
  category        = "env"
  description     = "Vault auth path"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
}