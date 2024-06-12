output "azure_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "app_vault_client_id" {
  value = azuread_application.vault.client_id
}

output "app_vault_client_secret" {
  value     = azuread_service_principal_password.vault.value
  sensitive = true
}

output "app_tfe_onboarding_object_id" {
  value = azuread_application.tfe_onboarding.object_id
}