/*******************************************
Azure | Azure Entra ID
*******************************************/
# Data Source(s): Current Azure Entra Session Details
data "azuread_client_config" "current" {}

# Data Source(s): Azure Native Applications, MSGraph
data "azuread_application_published_app_ids" "well_known" {}
data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# Resource(s): Azure Application: Vault Azure Secrets Engine
resource "azuread_application" "vault" {
  display_name = var.azure_app_azure_secrets_engine
  description  = "vault root account for azure secrets engine"
  owners       = [data.azuread_client_config.current.object_id]
  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.client_id
    dynamic "resource_access" {
      for_each = toset(local.vault_permissions.scope)
      content {
        id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids[resource_access.key]
        type = "Scope"
      }
    }
    dynamic "resource_access" {
      for_each = toset(local.vault_permissions.role)
      content {
        id   = data.azuread_service_principal.msgraph.app_role_ids[resource_access.key]
        type = "Role"
      }
    }
  }
}

# Resource(s): Azure Service Principal: Vault Azure Secrets Engine
resource "azuread_service_principal" "vault" {
  client_id = azuread_application.vault.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Resource(s): Azure Service Principal Client Secret: Vault Azure Secrets Engine
resource "azuread_service_principal_password" "vault" {
  service_principal_id = azuread_service_principal.vault.id
}

# Resource(s): Grant Admin Privileges: Vault Azure Secrets Engine
resource "azuread_app_role_assignment" "vault" {
  for_each            = toset(local.vault_permissions.role)
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids[each.key]
  principal_object_id = azuread_service_principal.vault.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Resource(s): Azure Application: Azure Project Onboarding
resource "azuread_application" "onboarding" {
  display_name = var.azure_app_onboarding
  description  = "management account for tfe onboarding"
  owners       = [data.azuread_client_config.current.object_id]
  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.client_id
    dynamic "resource_access" {
      for_each = toset(local.onboarding_permissions.scope)
      content {
        id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids[resource_access.key]
        type = "Scope"
      }
    }
    dynamic "resource_access" {
      for_each = toset(local.onboarding_permissions.role)
      content {
        id   = data.azuread_service_principal.msgraph.app_role_ids[resource_access.key]
        type = "Role"
      }
    }
  }
}

# Resource(s): Azure Service Principal: Azure Project Onboarding
resource "azuread_service_principal" "onboarding" {
  client_id = azuread_application.onboarding.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Resource(s): Grant Admin Privileges: Azure Project Onboarding
resource "azuread_app_role_assignment" "onboarding" {
  for_each            = toset(local.onboarding_permissions.role)
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids[each.key]
  principal_object_id = azuread_service_principal.onboarding.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Resource(s): Azure Eventual Consistency Buffer (30 seconds)
resource "time_sleep" "seconds_30" {
  depends_on      = [azuread_service_principal.onboarding]
  create_duration = "30s"
}

/*******************************************
Vault
*******************************************/

# Resource(s): Vault JWT Auth Backend
resource "vault_jwt_auth_backend" "this" {
  description        = "JWT auth for Terraform Workload Identity"
  path               = var.vault_auth_path
  oidc_discovery_url = var.terraform_addr
  bound_issuer       = var.terraform_addr
}

# Resource(s): Vault JWT Auth Backend Role: Terraform Workload Identity
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
    sub = "organization:${var.terraform_org_name}:project:${var.terraform_onboarding_project_name}:workspace:*:run_phase:*"
  }
  user_claim    = "terraform_full_workspace"
  role_type     = "jwt"
  token_ttl     = var.default_ttl
  token_max_ttl = var.max_ttl
}

# Resource(s): Vault Policy: Terraform Workload Identity
resource "vault_policy" "terraform" {
  name = var.vault_policy_name
  policy = templatefile("${path.module}/policy.tftpl", {
    azure_secrets_path     = var.vault_azure_secrets_path
    azure_secrets_role     = var.vault_azure_secrets_role
    terraform_secrets_path = var.vault_terraform_secrets_path
    terraform_secrets_role = var.vault_terraform_secrets_role
    terraform_auth_path    = var.vault_auth_path
    static_secrets_path    = var.vault_static_secrets_path
    static_github_key      = var.vault_static_github_key
    static_terraform_key   = var.vault_static_terraform_key
  })
}

# Resource(s): Vault Secrets Mount: Azure
resource "vault_azure_secret_backend" "this" {
  depends_on      = [time_sleep.seconds_30]
  path            = var.vault_azure_secrets_path
  subscription_id = "unknown"
  description     = "Azure Secrets Engine for Azure Project Onboarding"
  tenant_id       = data.azuread_client_config.current.tenant_id
  client_id       = azuread_service_principal.vault.client_id
  client_secret   = azuread_service_principal_password.vault.value
  environment     = "AzurePublicCloud"
}

# Resource(s): Vault Azure Secrets Engine Role: Azure Onboarding
resource "vault_azure_secret_backend_role" "this" {
  backend               = vault_azure_secret_backend.this.path
  role                  = var.vault_azure_secrets_role
  application_object_id = azuread_application.onboarding.object_id
  ttl                   = var.default_ttl
  max_ttl               = var.max_ttl
}

/* TODO: Troubleshoot Terraform Cloud Secrets Engine

# Resource(s): Vault Secrets Mount: Terraform Cloud (HCP Terraform)
resource "vault_terraform_cloud_secret_backend" "this" {
  backend     = var.vault_terraform_secrets_path
  description = "HCP Terraform Secrets Engine for Azure Project Onboarding"
  token       = var.terraform_token
}

# Resource(s): Vault Terraform Secrets Engine Role: Azure Onboarding
resource "vault_terraform_cloud_secret_role" "this" {
  backend = vault_terraform_cloud_secret_backend.this.backend
  name    = var.vault_terraform_secrets_role
  user_id = "" #TODO: Get User Id
  ttl     = var.default_ttl
  max_ttl = var.max_ttl
}

*/

# Resource(s): Vault Secrets Mount: Key Value version 2 (KVv2)
resource "vault_mount" "this" {
  path = var.vault_static_secrets_path
  type = "kv"
  options = {
    version = "2"
  }
  description = "KV version 2 Secrets Engine for Azure Project Onboarding"
}

# Resource(s): Vault Secret: GitHub token (Static)
resource "vault_kv_secret_v2" "github" {
  mount               = vault_mount.this.path
  name                = var.vault_static_github_key
  delete_all_versions = true
  data_json = jsonencode({
    token = var.github_token
  })
}

# Resource(s): Vault Secret: HCP Terraform token (Static)
resource "vault_kv_secret_v2" "terraform" {
  mount               = vault_mount.this.path
  name                = var.vault_static_terraform_key
  delete_all_versions = true
  data_json = jsonencode({
    token = var.terraform_token
  })
}

/*******************************************
HCP Terraform
*******************************************/

# Data Source(s): HCP Terraform GitHub App
data "tfe_github_app_installation" "this" {
  name = var.github_organization
}

# Resource(s): Terraform Project: Azure Project Onboarding
resource "tfe_project" "this" {
  organization = var.terraform_org_name
  name         = var.terraform_onboarding_project_name
  description  = "Onboarding for Azure Infrastructure Automation"
}

# Resource(s): Terraform Variable Set: Terraform Authentication to Vault
resource "tfe_variable_set" "vault_auth" {
  name         = "terraform-project-onboarding-vault-auth"
  description  = "Azure Project Onboarding: Terraform to Vault Authentication"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable Set Association: Azure Project Onboarding | Terraform Authentication to Vault
resource "tfe_project_variable_set" "vault_auth" {
  variable_set_id = tfe_variable_set.vault_auth.id
  project_id      = tfe_project.this.id
}

# Resource(s): Terraform Variable(s): Terraform Authentication to Vault
resource "tfe_variable" "vault_auth" {
  for_each        = local.common_terraform_vault
  key             = each.key
  value           = each.value.content
  category        = each.value.category
  description     = each.value.description
  variable_set_id = tfe_variable_set.vault_auth.id
}

# Resource(s): Terraform Variable Set: Vault-backed Azure Credentials
resource "tfe_variable_set" "vault_azure" {
  name         = "terraform-project-onboarding-vault-azure"
  description  = "Azure Project Onboarding: Terraform to Vault-backed Azure Credentials"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable Set Association: Azure Project Onboarding | Vault-backed Azure Credentials
resource "tfe_project_variable_set" "vault_azure" {
  variable_set_id = tfe_variable_set.vault_azure.id
  project_id      = tfe_project.this.id
}

# Resource(s): Terraform Variable(s): Vault-backed Azure Credentials
resource "tfe_variable" "vault_azure" {
  for_each        = local.common_terraform_vault_azure
  key             = each.key
  value           = each.value.content
  category        = each.value.category
  description     = each.value.description
  variable_set_id = tfe_variable_set.vault_azure.id
}

# Resource(s): Terraform Variable Set: Azure Project Onboarding
resource "tfe_variable_set" "this" {
  name         = var.terraform_variable_set_name
  description  = "Azure Project Onboarding: Auth & Secret Role(s)"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable Set Association: Azure Project Onboarding | Azure Project Onboarding
resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
}

# Resource(s): Terraform Variable(s): Azure Project Onboarding
resource "tfe_variable" "this" {
  for_each        = local.azure_onboarding
  key             = each.key
  value           = each.value.content
  category        = each.value.category
  description     = each.value.description
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Terraform Project: Production Workspaces
resource "tfe_project" "prod" {
  organization = var.terraform_org_name
  name         = "${var.prefix}-prod"
}

# Resource(s): Terraform Project: Development Workspaces
resource "tfe_project" "dev" {
  organization = var.terraform_org_name
  name         = "${var.prefix}-dev"
}

# Resource(s): Terraform Project: Staging Workspaces
resource "tfe_project" "stage" {
  organization = var.terraform_org_name
  name         = "${var.prefix}-stage"
}

# Resource(s): Terraform PMR Module: Azure Native Dynamic Credentials (Persistent SPN) Onboarding
resource "tfe_registry_module" "azure_native" {
  organization = var.terraform_org_name
  vcs_repo {
    display_identifier         = var.github_repo_azure_native
    identifier                 = var.github_repo_azure_native
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
  test_config {
    tests_enabled = false
  }
}

# Resource(s): Terraform No-Code Module: Azure Native Dynamic Credentials (Persistent SPN) Onboarding
resource "tfe_no_code_module" "azure_native" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.azure_native.id
}

# Resource(s): Terraform PMR Module: Azure Vault-Backed Dynamic Credentials (Persistent SPN) Onboarding
resource "tfe_registry_module" "azure_vault_static" {
  organization = var.terraform_org_name
  vcs_repo {
    display_identifier         = var.github_repo_azure_vault_static
    identifier                 = var.github_repo_azure_vault_static
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
  test_config {
    tests_enabled = false
  }
}

# Resource(s): Terraform No-Code Module: Azure Vault-Backed Dynamic Credentials (Persistent SPN) Onboarding
resource "tfe_no_code_module" "azure_vault_static" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.azure_vault_static.id
}

# Resource(s): Terraform PMR Module: Azure Vault-Backed Dynamic Credentials (Dynamic SPN) Onboarding
resource "tfe_registry_module" "azure_vault_dynamic" {
  organization = var.terraform_org_name
  vcs_repo {
    display_identifier         = var.github_repo_azure_vault_dynamic
    identifier                 = var.github_repo_azure_vault_dynamic
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
  test_config {
    tests_enabled = false
  }
}

# Resource(s): Terraform No-Code Module: Azure Vault-Backed Dynamic Credentials (Dynamic SPN) Onboarding
resource "tfe_no_code_module" "azure_vault_dynamic" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.azure_vault_dynamic.id
}