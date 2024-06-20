# Data Source(s): Current Session Details
data "azuread_client_config" "current" {}

# Data Source(s): Azure Native Applications, MSGraph
data "azuread_application_published_app_ids" "well_known" {}
data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# Resource(s): Azure Application for Vault Azure Secrets Engine
resource "azuread_application" "vault" {
  display_name = var.azure_app_azure_secrets_engine
  description  = "vault root account for azure secrets engine"
  owners       = [data.azuread_client_config.current.object_id]
  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.client_id
    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
      type = "Role"
    }
  }
}

# Resource(s): Azure Service Principal for Vault Azure Secrets Engine
resource "azuread_service_principal" "vault" {
  client_id = azuread_application.vault.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Resource(s): Azure Service Principal Client Secret for Vault Azure Secrets Engine Service Principal
resource "azuread_service_principal_password" "vault" {
  service_principal_id = azuread_service_principal.vault.id
}

# Resource(s): Azure Application for Terraform Project Onboarding
resource "azuread_application" "onboarding" {
  display_name = var.azure_app_terraform_onboarding
  description  = "management account for tfe onboarding"
  owners       = [data.azuread_client_config.current.object_id]
  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.client_id
    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
      type = "Role"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["AppRoleAssignment.ReadWrite.All"]
      type = "Role"
    }
  }
}

# Resource(s): Azure Service Principal for Terraform Project Onboarding
resource "azuread_service_principal" "onboarding" {
  client_id = azuread_application.onboarding.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Resource(s): Grant Admin Privileges for Vault Azure Secrets Engine Service Principal
resource "azuread_app_role_assignment" "vault" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
  principal_object_id = azuread_service_principal.vault.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Resource(s): Grant Admin Privileges for Terraform Project Onboarding Service Principal
resource "azuread_app_role_assignment" "onboarding" {
  for_each            = toset(["Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"])
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids[each.key]
  principal_object_id = azuread_service_principal.onboarding.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Resource(s): 30 second wait to account for Azure Eventual Consistency
resource "time_sleep" "seconds_30" {
  depends_on      = [azuread_service_principal.onboarding]
  create_duration = "30s"
}

# Resource(s): Vault JWT Auth Backend
resource "vault_jwt_auth_backend" "this" {
  description        = "JWT auth for Terraform Workload Identity"
  path               = var.vault_auth_path
  oidc_discovery_url = var.terraform_addr
  bound_issuer       = var.terraform_addr
}

# Resource(s): Vault JWT Auth Backend Role for Terraform Workload Identity
resource "vault_jwt_auth_backend_role" "terraform" {
  backend   = vault_jwt_auth_backend.this.path
  role_name = var.vault_auth_role_name
  token_policies = [
    "default",
    vault_policy.terraform.name
  ]
  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.terraform_org_name}:project:${var.terraform_project_name}:workspace:${var.terraform_workspace_name}:run_phase:${var.terraform_run_phase}"
  }
  user_claim    = "terraform_full_workspace"
  role_type     = "jwt"
  token_ttl     = var.default_ttl
  token_max_ttl = var.max_ttl
}

# Resource(s): Vault Policy to Authorize Terraform Workload Identity
resource "vault_policy" "terraform" {
  name = var.vault_policy_name
  policy = templatefile("${path.module}/policy.tftpl", {
    azure_secrets_path     = var.vault_azure_secrets_path
    azure_secrets_role     = var.vault_azure_secrets_role
    terraform_secrets_path = var.vault_terraform_secrets_path
    terraform_secrets_role = var.vault_terraform_secrets_role
    static_secrets_path    = var.vault_static_secrets_path
    static_github_key      = var.vault_static_github_key
    static_terraform_key   = var.vault_static_terraform_key
  })
}

# Resource(s): Azure Secrets Engine Mount
resource "vault_azure_secret_backend" "this" {
  depends_on      = [time_sleep.seconds_30]
  path            = var.vault_azure_secrets_path
  subscription_id = "unknown"
  description     = "Azure Secrets Engine for Terraform Project Onboarding"
  tenant_id       = data.azuread_client_config.current.tenant_id
  client_id       = azuread_service_principal.vault.client_id
  client_secret   = azuread_service_principal_password.vault.value
  environment     = "AzurePublicCloud"
}

# Resource(s): Azure Secrets Engine Role for Terraform Workload Identity
resource "vault_azure_secret_backend_role" "this" {
  backend               = vault_azure_secret_backend.this.path
  role                  = var.vault_azure_secrets_role
  application_object_id = azuread_application.onboarding.object_id
  ttl                   = var.default_ttl
  max_ttl               = var.max_ttl
}

# Resource(s): HCP Terraform Secrets Engine Mount
resource "vault_terraform_cloud_secret_backend" "this" {
  backend     = var.vault_terraform_secrets_path
  description = "HCP Terraform Secrets Engine for Terraform Project Onboarding"
  token       = local.tfe_credentials.credentials["app.terraform.io"].token
}

# Resource(s): HCP Terraform Secrets Engine Role for Terraform Workload Identity
resource "vault_terraform_cloud_secret_role" "this" {
  backend = vault_terraform_cloud_secret_backend.this.backend
  name    = var.vault_terraform_secrets_role
  user_id = "user-r6c8aSKE6ksKtw5X" # TODO
  ttl     = var.default_ttl
  max_ttl = var.max_ttl
}

# Resource(s): KVv2 Secrets Engine Mount
resource "vault_mount" "this" {
  path = var.vault_static_secrets_path
  type = "kv"
  options = {
    version = "2"
  }
  description = "KV version 2 Secrets Engine for Terraform Project Onboarding"
}

# Resource(s): KVv2 Secret for GitHub token
resource "vault_kv_secret_v2" "github" {
  mount               = vault_mount.this.path
  name                = var.vault_static_github_key
  delete_all_versions = true
  data_json = jsonencode({
    token = var.github_token
  })
}

# Resource(s): KVv2 Secret for HCP Terraform token
resource "vault_kv_secret_v2" "terraform" {
  mount               = vault_mount.this.path
  name                = var.vault_static_terraform_key
  delete_all_versions = true
  data_json = jsonencode({
    token = local.tfe_credentials.credentials["app.terraform.io"].token
  })
}

# Data Source(s): Import Environment Variables
data "external" "env" {
  program = ["jq", "-n", "env"]
}

# Resource(s): Terraform Project for Terraform Project Onboarding
resource "tfe_project" "this" {
  organization = var.terraform_org_name
  name         = var.terraform_project_name
}

# Resource(s): Terraform Variable Set for Terraform Project Onboarding
resource "tfe_variable_set" "this" {
  name         = var.terraform_variable_set_name
  description  = "Vault-backed Workload Identity"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable TFC_VAULT_ADDR
resource "tfe_variable" "vault_addr" {
  key             = "TFC_VAULT_ADDR"
  value           = data.external.env.result.VAULT_ADDR
  category        = "env"
  description     = "Vault FQDN"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_NAMESPACE
resource "tfe_variable" "vault_namespace" {
  key             = "TFC_VAULT_NAMESPACE"
  value           = data.external.env.result.VAULT_NAMESPACE
  category        = "env"
  description     = "Vault Namespace"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_PROVIDER_AUTH
resource "tfe_variable" "enable_vault_auth" {
  key             = "TFC_VAULT_PROVIDER_AUTH"
  value           = true
  category        = "env"
  description     = "Enable Vault Provider auth"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_RUN_ROLE
resource "tfe_variable" "vault_run_role" {
  key             = "TFC_VAULT_RUN_ROLE"
  value           = vault_jwt_auth_backend_role.terraform.role_name
  category        = "env"
  description     = "Vault auth role"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_AUTH_PATH
resource "tfe_variable" "vault_auth_path" {
  key             = "TFC_VAULT_AUTH_PATH"
  value           = vault_jwt_auth_backend.this.path
  category        = "env"
  description     = "Vault auth path"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE
resource "tfe_variable" "vault_azure_auth" {
  key             = "TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE"
  value           = vault_azure_secret_backend_role.this.role
  category        = "env"
  description     = "Vault-backed Azure Auth role"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_BACKED_AZURE_AUTH
resource "tfe_variable" "vault_azure_auth_role" {
  key             = "TFC_VAULT_BACKED_AZURE_AUTH"
  value           = true
  category        = "env"
  description     = "Enable Vault-backed Azure Dynamic Credentials"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_BACKED_AZURE_MOUNT_PATH
resource "tfe_variable" "vault_azure_auth_path" {
  key             = "TFC_VAULT_BACKED_AZURE_MOUNT_PATH"
  value           = vault_azure_secret_backend.this.path
  category        = "env"
  description     = "Azure Auth mount path"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Variable TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS (Eventual Consistency)
resource "tfe_variable" "vault_azure_sleep_seconds" {
  key             = "TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS"
  value           = 30
  category        = "env"
  description     = "Sleep Seconds"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Associate Variable Set to Project
resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
}

# Resource(s): Terraform Variable PREFIX
resource "tfe_variable" "prefix" {
  key             = "prefix"
  value           = var.prefix
  category        = "terraform"
  description     = "prefix"
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Project for Production
resource "tfe_project" "prod" {
  organization = var.terraform_org_name
  name         = "${var.prefix}-prod"
}

# Resource(s): Terraform Project for Development
resource "tfe_project" "dev" {
  organization = var.terraform_org_name
  name         = "${var.prefix}-dev"
}

# Resource(s): Terraform Project for Staging
resource "tfe_project" "stage" {
  organization = var.terraform_org_name
  name         = "${var.prefix}-stage"
}

# Data Source(s): HCP Terraform GitHub App
data "tfe_github_app_installation" "this" {
  name = "kevin-loehfelm"
}

# Resource(s): Publish Project Module to PMR
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

# Resource(s): Configure Published Module as No-Code Module
resource "tfe_no_code_module" "this" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.this.id
}
