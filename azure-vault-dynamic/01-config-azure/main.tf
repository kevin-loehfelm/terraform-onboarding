data "azuread_client_config" "current" {}

# Create App Registration
resource "azuread_application" "this" {
  display_name = var.azure_application_name
  description  = "root account for Vault's Azure secrets engine"
  owners       = [data.azuread_client_config.current.object_id]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    resource_access {
      id   = "18a4783c-866b-4cc7-a460-3d5e5662c884" # Application.ReadWrite.OwnedBy
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"
}

resource "terraform_data" "enable_azure_permissions" {
  depends_on = [time_sleep.wait_5_seconds]
  provisioner "local-exec" {
    command = "curl -X POST -H 'Content-Type: application/json' -H \"Authorization: Bearer $(cat ~/.doormat/doormat.crt)\" -d '{\"app_object_id\":\"${azuread_application.this.object_id}\", \"tenant_id\":\"237fbc04-c52a-458b-af97-eaf7157c0cd4\", \"use_case\":\"vault-secrets-engine\"}' https://doormat.hashicorp.services/api/1/azure/add-app-permissions"
  }
}