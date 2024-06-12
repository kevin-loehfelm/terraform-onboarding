# Module: Configure Azure
module "azure_config" {
  source = "./01-config-azure"

  app_vault_spn_name          = "vault--azure-secrets-engine"
  app_tfe_onboarding_spn_name = "tfe-onboarding"
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.azure_config]

  create_duration = "30s"
}

# Module: Configure Vault
module "vault_config" {
  depends_on = [time_sleep.wait_30_seconds]

  source = "./02-config-vault"

  # Azure Environment
  azure_tenant_id              = module.azure_config.azure_tenant_id
  app_vault_client_id          = module.azure_config.app_vault_client_id
  app_vault_client_secret      = module.azure_config.app_vault_client_secret
  app_tfe_onboarding_object_id = module.azure_config.app_tfe_onboarding_object_id

  # Terraform Auth
  terraform_auth_path                    = "terraform_jwt"
  terraform_auth_policy_name             = "terraform-workload-identity"
  terraform_auth_role                    = "terraform-workload-identity"
  terraform_workspace_subject_identifier = "organization:${var.terraform_org_name}:project:${var.terraform_project_name}:workspace:${var.terraform_workspace_name}:run_phase:${var.terraform_run_phase}"

  # Azure Secrets Engine
  azure_secrets_engine_path = "azure"
  azure_secrets_engine_role = "terraform"
}

# Module: Configure Terraform
module "terraform_config" {
  source = "./03-config-terraform"

  organization_name = var.terraform_org_name
  project_name      = var.terraform_project_name
  workspace_name    = var.terraform_workspace_name

  terraform_auth_path = "terraform_jwt"
  terraform_auth_role = "terraform-workload-identity"
  terraform_team_name = "terraform-workload-identity"

  azure_secrets_engine_path = "azure"
  azure_secrets_engine_role = "terraform"

  github_token = var.github_token
}

## Data Source(s): HCP Terraform GitHub App
data "tfe_github_app_installation" "this" {
  name = "kevin-loehfelm"
}

## Resource(s): Publish Project Module to PMR
resource "tfe_registry_module" "this" {
  organization = var.terraform_org_name
  vcs_repo {
    display_identifier         = var.github_workspace_module_repo
    identifier                 = var.github_workspace_module_repo
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
  test_config {
    tests_enabled = false
  }
}

## Resource(s): Configure Published Module as No-Code Module
resource "tfe_no_code_module" "this" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.this.id
}
