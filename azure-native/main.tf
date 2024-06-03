# Configure Azure
module "azure_config" {
  source = "./01-config-azure"
}

resource "tfe_team" "this" {
  name         = var.vault_azure_secrets_engine_path
  organization = "kloehfelm-demo"
    organization_access {
    manage_vcs_settings = true
  }
}

resource "tfe_team_token" "this" {
  team_id = tfe_team.this.id
}

# Configure Vault
module "vault_config" {
  source = "./02-config-vault"

  vault_auth_path      = var.vault_auth_path
  vault_policy_name    = var.vault_policy_name
  vault_auth_role_name = var.vault_auth_role_name

  terraform_addr               = var.terraform_addr
  terraform_subject_identifier = "organization:${var.terraform_org_name}:project:${var.terraform_project_name}:workspace:${var.terraform_workspace_name}:run_phase:${var.terraform_run_phase}"
  terraform_token_ttl          = var.terraform_token_ttl
  terraform_token              = tfe_team_token.this

  vault_azure_secrets_engine_path = var.vault_azure_secrets_engine_path
  azure_object_id                 = module.azure_config.azure_object_id
  azure_client_id                 = module.azure_config.azure_client_id
  azure_client_secret             = module.azure_config.azure_client_secret
  azure_tenant_id                 = module.azure_config.azure_tenant_id
}

# Configure Terraform
module "terraform_config" {
  source = "./03-config-terraform"

  terraform_org_name       = var.terraform_org_name
  terraform_project_name   = var.terraform_project_name
  terraform_workspace_name = var.terraform_workspace_name
  vault_auth_path          = module.vault_config.vault_auth_path
  vault_auth_role_name     = module.vault_config.vault_auth_role_name
}