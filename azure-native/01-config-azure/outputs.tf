output "azure_object_id" {
  value = azuread_application.this.object_id
}

output "azure_client_id" {
  value = azuread_application.this.client_id
}

output "azure_client_secret" {
  sensitive = true
  value     = azuread_service_principal_password.this.value
}

output "azure_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}