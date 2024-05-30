# Configure Azure
module "azure_config" {
  source = "./01-config-azure"
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
}