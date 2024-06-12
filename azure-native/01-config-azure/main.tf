# Read Current Session Details
data "azuread_client_config" "current" {}

# Read Azure Native Applications
data "azuread_application_published_app_ids" "well_known" {}
data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# Create App Registration & Service Principal for Azure Secrets Engine
resource "azuread_application" "vault" {
  display_name = var.app_vault_spn_name
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

resource "azuread_service_principal" "vault" {
  client_id = azuread_application.vault.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "vault" {
  service_principal_id = azuread_service_principal.vault.id
}

# Create App Registration & Service Principal for TFE Onboarding
resource "azuread_application" "tfe_onboarding" {
  display_name = var.app_tfe_onboarding_spn_name
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

resource "azuread_service_principal" "tfe_onboarding" {
  client_id = azuread_application.tfe_onboarding.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Grant Admin Privileges for Azure Secrets Engine SPN
resource "azuread_app_role_assignment" "vault" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
  principal_object_id = azuread_service_principal.vault.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Grant Admin Privileges for TFE Onboarding SPN
resource "azuread_app_role_assignment" "tfe_onboarding" {
  for_each            = toset(["Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"])
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids[each.key]
  principal_object_id = azuread_service_principal.tfe_onboarding.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}