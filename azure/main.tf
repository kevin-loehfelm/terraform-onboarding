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
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["GroupMember.ReadWrite.All"]
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
    resource_access {
      id = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
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
  for_each            = toset(["Application.ReadWrite.All", "GroupMember.ReadWrite.All"])
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids[each.key]
  principal_object_id = azuread_service_principal.vault.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Resource(s): Grant Admin Privileges for Terraform Project Onboarding Service Principal
resource "azuread_app_role_assignment" "onboarding" {
  for_each            = toset(["Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All", "Group.ReadWrite.All"])
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
    terraform_auth_path    = var.vault_auth_path
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
  description  = "Onboarding for Azure Infrastructure Automation"
}

# Resource(s): Terraform Variable Set for Terraform Auth to Vault
resource "tfe_variable_set" "vault_auth" {
  name         = "terraform-project-onboarding-vault-auth"
  description  = "Terraform Project Onboarding: Terraform to Vault Authentication"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable(s) for Terraform Auth to Vault
resource "tfe_variable" "vault_auth" {
  for_each        = local.common_terraform_vault
  key             = each.key
  value           = each.value.content
  category        = each.value.category
  description     = each.value.description
  variable_set_id = tfe_variable_set.vault_auth.id
}

# Resource(s): Associate Variable Set to Project
resource "tfe_project_variable_set" "vault_auth" {
  variable_set_id = tfe_variable_set.vault_auth.id
  project_id      = tfe_project.this.id
}

# Resource(s): Terraform Variable Set for Vault-backed Azure Credentials
resource "tfe_variable_set" "vault_azure" {
  name         = "terraform-project-onboarding-vault-azure"
  description  = "Terraform Project Onboarding: Terraform to Vault-backed Azure"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable(s) for Vault-backed Azure Credentials
resource "tfe_variable" "vault_azure" {
  for_each        = local.common_terraform_vault_azure
  key             = each.key
  value           = each.value.content
  category        = each.value.category
  description     = each.value.description
  variable_set_id = tfe_variable_set.vault_azure.id
}

# Resource(s): Associate Variable Set to Project
resource "tfe_project_variable_set" "vault_azure" {
  variable_set_id = tfe_variable_set.vault_azure.id
  project_id      = tfe_project.this.id
}

# Resource(s): Terraform Variable Set for Terraform Project Onboarding
resource "tfe_variable_set" "this" {
  name         = var.terraform_variable_set_name
  description  = "Terraform Project Onboarding: Auth & Secret Role(s)"
  organization = var.terraform_org_name
}

# Resource(s): Terraform Variable(s) for Terraform Project Onboarding
resource "tfe_variable" "this" {
  for_each        = local.terraform_onboarding
  key             = each.key
  value           = each.value.content
  category        = each.value.category
  description     = each.value.description
  variable_set_id = tfe_variable_set.this.id
}

# Resource(s): Associate Variable Set to Project
resource "tfe_project_variable_set" "this" {
  variable_set_id = tfe_variable_set.this.id
  project_id      = tfe_project.this.id
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

# Resource(s): Azure Native Dynamic Credentials (Persistent SPN) Onboarding Module
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

# Resource(s): Azure Native Dynamic Credentials (Persistent SPN) No-Code Module
resource "tfe_no_code_module" "azure_native" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.azure_native.id
}

# Resource(s): Azure Vault-Backed Dynamic Credentials (Persistent SPN) Onboarding Module
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

# Resource(s): Azure Vault-Backed Dynamic Credentials (Persistent SPN) No-Code Module
resource "tfe_no_code_module" "azure_vault_static" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.azure_vault_static.id
}

# Resource(s): Azure Vault-Backed Dynamic Credentials (Dynamic SPN) Onboarding Module
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

# Resource(s): Azure Vault-Backed Dynamic Credentials (Dynamic SPN) No-Code Module
resource "tfe_no_code_module" "azure_vault_dynamic" {
  organization    = var.terraform_org_name
  registry_module = tfe_registry_module.azure_vault_dynamic.id
}