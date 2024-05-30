output "vault_auth_role_name" {
  value = vault_jwt_auth_backend_role.this.role_name
}

output "vault_auth_path" {
  value = vault_jwt_auth_backend.this.path
}